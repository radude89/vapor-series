import Vapor

struct PersonResponseContent: Content {
    let id: UUID
    let name: String
    let dateOfBirth: Date?
    let isActive: Bool
    let eyeColor: String?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
}

// MARK: - Helpers

extension PersonResponseContent {
    init(person: Person) throws {
        id = try person.requireID()
        name = person.name
        dateOfBirth = person.dateOfBirth
        isActive = person.isActive
        eyeColor = person.eyeColor?.rawValue
        createdAt = person.createdAt
        updatedAt = person.updatedAt
        deletedAt = person.deletedAt
    }
}
