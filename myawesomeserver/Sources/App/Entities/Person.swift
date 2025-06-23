import Fluent
import Foundation

final class Person: Model, @unchecked Sendable {
    static let schema = "persons"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @OptionalField(key: "date_of_birth")
    var dateOfBirth: Date?

    @OptionalEnum(key: "eye_color")
    var eyeColor: EyeColor?

    @Boolean(key: "is_active")
    var isActive: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    @OptionalChild(for: \.$person)
    var passport: Passport?

    init() {}

    init(
        id: UUID? = nil,
        name: String,
        dateOfBirth: Date? = nil,
        eyeColor: EyeColor? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.eyeColor = eyeColor
        self.isActive = isActive
    }
}

enum EyeColor: String, Codable {
    case blue, black, other
}
