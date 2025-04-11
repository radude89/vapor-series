import Vapor
import Foundation

struct PersonsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let persons = routes.grouped("persons")

        // CREATE
        persons.post { request in
            try await createPerson(request: request)
        }

        // READ
        persons.get { request in
            try await getPersons(request: request)
        }

        persons.get(":id") { request in
            try await getPerson(request: request)
        }

        // UPDATE
        persons.put(":id") { request in
            try await updatePerson(request: request)
        }

        // DELETE
        persons.delete(":id") { request in
            try await deletePerson(request: request)
        }
    }

    // MARK: - Create

    @Sendable
    private func createPerson(request: Request) async throws -> PersonResponseContent {
        let requestContent = try request.content.decode(PersonRequestContent.self)
        guard let name = requestContent.name else {
            throw Abort(.badRequest, reason: "Name is required")
        }

        let person = Person(requestContent: requestContent, name: name)
        try await person.save(on: request.db)

        return try PersonResponseContent(person: person)
    }

    // MARK: - Read

    @Sendable
    private func getPersons(request: Request) async throws -> [PersonResponseContent] {
        let persons: [Person] = try await Person.query(on: request.db).withDeleted().all()
        return try persons.map { person in
            try PersonResponseContent(person: person)
        }
    }

    @Sendable
    private func getPerson(request: Request) async throws -> PersonResponseContent {
        let id: UUID? = request.parameters.get("id")

        guard let person = try await Person.find(id, on: request.db) else {
            throw Abort(.notFound)
        }

        return try PersonResponseContent(person: person)
    }

    // MARK: - Update

    @Sendable
    private func updatePerson(request: Request) async throws -> PersonResponseContent {
        let id: UUID? = request.parameters.get("id")

        guard let person = try await Person.find(id, on: request.db) else {
            throw Abort(.notFound)
        }

        let requestContent = try request.content.decode(PersonRequestContent.self)
        person.setValue(requestContent.name, to: \.name)
        person.setValue(requestContent.dateOfBirth, to: \.dateOfBirth)
        person.setValue(requestContent.isActive, to: \.isActive)
        person.setEyeColor(requestContent.eyeColor)
        try await person.update(on: request.db)

        return try PersonResponseContent(person: person)
    }

    // MARK: - DELETE

    @Sendable
    private func deletePerson(request: Request) async throws -> HTTPStatus {
        let id: UUID? = request.parameters.get("id")

        guard let person = try await Person.find(id, on: request.db) else {
            throw Abort(.notFound)
        }

        try await person.delete(on: request.db)

        return HTTPStatus.noContent
    }
}

// MARK: - Private helpers

private extension Person {
    func setValue<Value>(
        _ value: Value?,
        to keyPath: ReferenceWritableKeyPath<Person, Value>
    ) {
        if let value {
            self[keyPath: keyPath] = value
        }
    }

    func setEyeColor(_ colorRawValue: String?) {
        if let colorRawValue {
            eyeColor = EyeColor(rawValue: colorRawValue)
        }
    }
}
