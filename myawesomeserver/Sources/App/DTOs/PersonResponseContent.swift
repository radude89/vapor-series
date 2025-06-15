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

struct PassportResponseContent: Content {
    let id: UUID
    let number: String

    init(id: UUID, number: String) {
        self.id = id
        self.number = number
    }
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

extension PassportResponseContent {
    init?(passport: Passport?) throws {
        guard let passport else { return nil }
        id = try passport.requireID()
        number = passport.passportNumber
    }
}
