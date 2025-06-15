import Fluent
import Foundation

final class Passport: Model, @unchecked Sendable {
    static let schema = "passports"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "person_id")
    var person: Person

    @Field(key: "passport_number")
    var passportNumber: String

    init() {}

    init(
        id: UUID? = nil,
        passportNumber: String,
        personID: Person.IDValue,
    ) {
        self.id = id
        self.passportNumber = passportNumber
        self.$person.id = personID
    }
}
