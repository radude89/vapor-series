import Vapor
import Foundation
import Fluent

struct PersonsController: RouteCollection, Sendable {
    func boot(routes: any RoutesBuilder) throws {
        let persons = routes.grouped("persons")
        let moodLogs = persons.grouped(":id", "moodlogs")
        let languages = persons.grouped(":id", "languages")

        // CREATE
        persons.post { request in
            try await createPerson(request: request)
        }
        
        moodLogs.post { request in
            try await createMoodLogForPerson(request: request)
        }
        
        languages.post { request in
            try await learnLanguage(request: request)
        }

        // READ
        persons.get { request in
            try await getPersons(request: request)
        }

        persons.get(":id") { request in
            try await getPerson(request: request)
        }
        
        persons.get("names") { request in
            try await getAllNames(request: request)
        }
        
        persons.get("search") { request in
            try await getPersonsByName(request: request)
        }
        
        moodLogs.get { request in
            try await getMoodLogsForPerson(request: request)
        }
        
        languages.get { request in
            try await getPersonLanguages(request: request)
        }
        
        persons.get("passports") { request in
            try await getPersonsWithPasport(request: request)
        }

        // UPDATE
        persons.put(":id") { request in
            try await updatePerson(request: request)
        }
        
        persons.put("deactivate") { request in
            try await deactivatePersonsByName(request: request)
        }
        
        persons.get("count") { request in
            try await getNumberOfPersons(request: request)
        }

        // DELETE
        persons.delete(":id") { request in
            try await delete(Person.self, request: request)
        }
        
        persons.delete { request in
            try await deletePersonsByName(request: request)
        }
        
        languages.delete(":language_id") { request in
            try await forgetLanguage(request: request)
        }
    }

    // MARK: - Create

    private func createPerson(request: Request) async throws -> PersonResponseContent {
        let requestContent = try request.content.decode(PersonRequestContent.self)
        guard let name = requestContent.name else {
            throw Abort(.badRequest, reason: "Name is required")
        }

        let person = Person(requestContent: requestContent, name: name)
        try await person.create(on: request.db)

        try await createPassportIfNeeded(
            requestContent: requestContent.passport,
            person: person,
            request: request
        )

        return try await PersonResponseContent(
            person: person,
            passport: person.$passport.get(on: request.db)
        )
    }
    
    private func createPassportIfNeeded(
        requestContent: PassportRequestContent?,
        person: Person,
        request: Request
    ) async throws {
        guard let requestContent else { return }
            
        let passport = Passport(
            passportNumber: requestContent.number,
            personID: try person.requireID()
        )
        try await passport.create(on: request.db)
    }
    
    private func createMoodLogForPerson(
        request: Request
    ) async throws -> MoodLogResponseContent {
        let personID: UUID? = request.parameters.get("id")
        
        guard let person = try await Person.find(personID, on: request.db) else {
            throw Abort(.notFound)
        }
        
        let requestContent = try request.content.decode(MoodLogRequestContent.self)
        let moodLog = MoodLog(
            personID: try person.requireID(),
            mood: requestContent.mood,
            note: requestContent.note
        )
        try await moodLog.create(on: request.db)
        
        return try MoodLogResponseContent(moodLog: moodLog)
    }
    
    private func learnLanguage(request: Request) async throws -> HTTPStatus {
        let person: Person = try await findByID(request: request)
        let requestContent = try request.content.decode(PersonLanguageRequestContent.self)
        let language = try await createLanguageIfNeeded(
            requestContent: requestContent,
            request: request
        )
        
        if try await person.$languages.isAttached(to: language, on: request.db) {
            throw Abort(.conflict, reason: "Person already speaks this language")
        }
        
        try await person.$languages.attach(language, on: request.db) { personLanguage in
            personLanguage.dateLearnt = Date()
            personLanguage.isPrimary = requestContent.isPrimary
        }
        
        return .created
    }
    
    private func createLanguageIfNeeded(
        requestContent: PersonLanguageRequestContent,
        request: Request
    ) async throws -> Language {
        if let language = try await Language.query(on: request.db)
            .filter(\.$code, .equal, requestContent.code)
            .first() {
            return language
        } else {
            let language = Language(code: requestContent.code)
            try await language.create(on: request.db)
            return language
        }
    }

    // MARK: - Read

    private func getPersons(request: Request) async throws -> Page<PersonResponseContent> {
        try await Person
            .query(on: request.db)
            .chunk(max: 2) { results in
                for (index, result) in results.enumerated() {
                    switch result {
                    case .success(let person):
                        print("### Processed \(person.name). Chunk no. \(index) out of \(results.count)")
                    case .failure(let error):
                        print("### Failed to process at index \(index). Encountered error: \(error.localizedDescription)")
                    }
                }
            }

        return try await Person
            .query(on: request.db)
            .withDeleted()
            .with(\.$passport)
            .paginate(for: request)
            .map { try PersonResponseContent(person: $0, passport: $0.passport) }
    }

    private func getPerson(request: Request) async throws -> PersonResponseContent {
        let person: Person = try await findByID(request: request)
        let passport = try await person.$passport.get(on: request.db)
        return try PersonResponseContent(person: person, passport: passport)
    }
    
    private func getMoodLogsForPerson(request: Request) async throws -> [MoodLogResponseContent] {
        let person: Person = try await findByID(request: request)
        return try await person.$moodLogs.get(on: request.db).map { moodLog in
            try MoodLogResponseContent(moodLog: moodLog)
        }
    }
    
    private func getPersonLanguages(request: Request) async throws -> [PersonLanguageResponseContent] {
        let person: Person = try await findByID(request: request)
        let personLanguages = try await PersonLanguage.query(on: request.db)
            .filter(\.$person.$id, .equal, person.requireID())
            .with(\.$language)
            .all()
        
        return try personLanguages.map { personLanguage in
            try PersonLanguageResponseContent(
                personLanguage: personLanguage,
                person: person
            )
        }
    }
    
    private func getAllNames(request: Request) async throws -> [String] {
        try await Person.query(on: request.db).all(\.$name)
    }
    
    private func getPersonsByName(request: Request) async throws -> [PersonResponseContent] {
        guard let name = request.query[String.self, at: "name"] else {
            throw Abort(.badRequest, reason: "Name is required")
        }
        
        return try await Person
            .query(on: request.db)
            .group(.or) { group in
                group.filter(\.$name =~ name)
                    .filter(\.$name ~= name)
                    .filter(\.$name ~~ name)
            }
            .with(\.$passport)
            .all()
            .map { try PersonResponseContent(person: $0, passport: $0.passport) }
    }
    
    private func getPersonsWithPasport(request: Request) async throws -> [PersonResponseContent] {
        try await Person
            .query(on: request.db)
            .join(Passport.self, on: \Person.$id == \Passport.$person.$id)
            .with(\.$passport)
            .all()
            .map{ try PersonResponseContent(person: $0, passport: $0.passport) }
    }
    
    private func getNumberOfPersons(request: Request) async throws -> Int {
        try await Person.query(on: request.db).count()
    }

    // MARK: - Update

    private func updatePerson(request: Request) async throws -> PersonResponseContent {
        let person: Person = try await findByID(request: request)

        let requestContent = try request.content.decode(PersonRequestContent.self)
        person.setValue(requestContent.name, to: \.name)
        person.setValue(requestContent.dateOfBirth, to: \.dateOfBirth)
        person.setValue(requestContent.isActive, to: \.isActive)
        person.setEyeColor(requestContent.eyeColor)
        
        try await updatePassportIfNeeded(
            requestContent: requestContent.passport,
            person: person,
            request: request
        )
        
        try await person.update(on: request.db)

        return try PersonResponseContent(
            person: person,
            passport: try await person.$passport.get(reload: true, on: request.db)
        )
    }
    
    private func updatePassportIfNeeded(
        requestContent: PassportRequestContent?,
        person: Person,
        request: Request
    ) async throws {
        guard let requestContent else { return }
            
        let passport = try await person.$passport.get(on: request.db)
        if let passport {
            passport.passportNumber = requestContent.number
            try await passport.update(on: request.db)
        } else {
            try await createPassportIfNeeded(
                requestContent: requestContent,
                person: person,
                request: request
            )
        }
    }
    
    private func deactivatePersonsByName(request: Request) async throws -> HTTPStatus {
        guard let name: String = try request.content.get(at: "name") else {
            throw Abort(.badRequest, reason: "Name is required")
        }
        
        try await Person.query(on: request.db)
            .filter(\.$name =~ name)
            .set(\.$isActive, to: false)
            .update()
        
        return .noContent
    }
    
    // MARK: - Delete
    
    private func forgetLanguage(request: Request) async throws -> HTTPStatus {
        let person: Person = try await findByID(request: request)
        let language: Language = try await findByID(request: request, idParamName: "language_id")
        try await person.$languages.detach(language, on: request.db)
        return .noContent
    }
    
    private func deletePersonsByName(request: Request) async throws -> HTTPStatus {
        guard let name: String = try request.content.get(at: "name") else {
            throw Abort(.badRequest, reason: "Name is required")
        }
        
        try await Person.query(on: request.db)
            .filter(\.$name =~ name)
            .delete()
        
        return .noContent
    }
}

// MARK: - Private helpers

private extension Person {
    func setEyeColor(_ colorRawValue: String?) {
        if let colorRawValue {
            eyeColor = EyeColor(rawValue: colorRawValue)
        }
    }
}
