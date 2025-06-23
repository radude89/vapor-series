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
    let passport: PassportResponseContent?
}

// MARK: - Helpers

extension PersonResponseContent {
    init(person: Person, passport: Passport? = nil) throws {
        id = try person.requireID()
        name = person.name
        dateOfBirth = person.dateOfBirth
        isActive = person.isActive
        eyeColor = person.eyeColor?.rawValue
        createdAt = person.createdAt
        updatedAt = person.updatedAt
        deletedAt = person.deletedAt
        self.passport = try PassportResponseContent(passport: passport)
    }
}
