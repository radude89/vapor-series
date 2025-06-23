import Vapor

struct PassportResponseContent: Content {
    let id: UUID
    let number: String
}

// MARK: - Helpers

extension PassportResponseContent {
    init?(passport: Passport?) throws {
        guard let passport else { return nil }
        id = try passport.requireID()
        number = passport.passportNumber
    }
}
