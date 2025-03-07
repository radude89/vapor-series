import Vapor

nonisolated(unsafe) var persons: [Person] = []

struct PersonsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let persons = routes.grouped("persons")

        // CREATE
        persons.post { request in
            try createPerson(request: request)
        }

        // READ
        persons.get { _ in getPersons() }

        persons.get(":id") { request in
            try getPerson(request: request)
        }

        // UPDATE
        persons.put(":id") { request in
            try updatePerson(request: request)
        }

        // DELETE
        persons.delete(":id") { request in
            try deletePerson(request: request)
        }
    }

    // MARK: - Create

    private func createPerson(request: Request) throws -> Person {
        let requestObject = try request.content.decode(CreatePerson.self)
        let newPerson = Person(
            name: requestObject.name,
            dateOfBirth: requestObject.dateOfBirth
        )
        persons.append(newPerson)
        return newPerson
    }

    // MARK: - Read

    private func getPersons() -> [Person] {
        persons
    }

    private func getPerson(request: Request) throws -> Person {
        let id: UUID? = request.parameters.get("id")

        if let person = persons.first(where: { $0.id == id }) {
            return person
        }
        throw Abort(.notFound)
    }

    // MARK: - Update

    private func updatePerson(request: Request) throws -> Person {
        let existingPerson = try getPerson(request: request)
        let requestObject = try request.content.decode(UpdatePerson.self)

        let updatedPerson = Person(
            id: existingPerson.id,
            name: requestObject.name ?? existingPerson.name,
            dateOfBirth: requestObject.dateOfBirth ?? existingPerson.dateOfBirth
        )

        var newPersonsArray = persons.filter { $0.id != existingPerson.id }
        newPersonsArray.append(updatedPerson)

        persons = newPersonsArray

        return updatedPerson
    }

    // MARK: - DELETE

    private func deletePerson(request: Request) throws -> HTTPStatus {
        let id: UUID? = request.parameters.get("id")

        guard let id else {
            throw Abort(.notFound)
        }

        persons = persons.filter { $0.id != id }

        return HTTPStatus.noContent
    }
}

struct CreatePerson: Content {
    let name: String
    let dateOfBirth: Date?
}

struct UpdatePerson: Content {
    let name: String?
    let dateOfBirth: Date?
}
