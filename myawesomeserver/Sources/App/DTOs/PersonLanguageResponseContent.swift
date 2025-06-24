import Vapor

struct PersonLanguageResponseContent: Content {
    let id: UUID
    let personID: UUID
    let languageID: UUID
    let languageCode: String
    let dateLearnt: Date?
    let isPrimary: Bool
    
    init(
        id: UUID,
        personID: UUID,
        languageID: UUID,
        languageCode: String,
        dateLearnt: Date?,
        isPrimary: Bool
    ) {
        self.id = id
        self.personID = personID
        self.languageID = languageID
        self.languageCode = languageCode
        self.dateLearnt = dateLearnt
        self.isPrimary = isPrimary
    }
}

// MARK: - Helpers

extension PersonLanguageResponseContent {
    init(
        personLanguage: PersonLanguage,
        person: Person
    ) throws {
        id = try personLanguage.requireID()
        personID = try person.requireID()
        let language = personLanguage.language
        languageID = try language.requireID()
        languageCode = language.code
        dateLearnt = personLanguage.dateLearnt
        isPrimary = personLanguage.isPrimary ?? false
    }
}
