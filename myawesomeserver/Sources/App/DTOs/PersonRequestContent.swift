import Vapor

struct PersonRequestContent: Content {
    let name: String?
    let dateOfBirth: Date?
    let isActive: Bool?
    let eyeColor: String?
    let passport: PassportRequestContent?
}

// MARK: - Helper for my Fluent model

extension Person {
    convenience init(
        requestContent: PersonRequestContent,
        name: String
    ) {
        self.init()
        self.name = name
        dateOfBirth = requestContent.dateOfBirth
        eyeColor = Self.getEyeColor(from: requestContent.eyeColor)
        isActive = requestContent.isActive ?? true
    }

    private static func getEyeColor(from value: String?) -> EyeColor? {
        guard let value else {
            return nil
        }

        return EyeColor(rawValue: value)
    }
}
