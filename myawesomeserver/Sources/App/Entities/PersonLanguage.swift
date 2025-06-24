import Fluent
import Foundation

final class PersonLanguage: Model, @unchecked Sendable {
    static let schema = "person+language"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "person_id")
    var person: Person
    
    @Parent(key: "language_id")
    var language: Language
    
    @OptionalField(key: "date_learnt")
    var dateLearnt: Date?
    
    @OptionalBoolean(key: "is_primary")
    var isPrimary: Bool?
    
    init() {}
    
    init(
        id: UUID? = nil,
        personID: Person.IDValue,
        languageID: Language.IDValue,
        dateLearnt: Date? = nil,
        isPrimary: Bool? = nil
    ) {
        self.id = id
        self.$person.id = personID
        self.$language.id = languageID
        self.dateLearnt = dateLearnt
        self.isPrimary = isPrimary
    }
}
