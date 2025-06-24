import Vapor

struct LanguageResponseContent: Content {
    let id: UUID
    let code: String
    
    init(id: UUID, code: String) {
        self.id = id
        self.code = code
    }
}

// MARK: - Helpers

extension LanguageResponseContent {
    init(language: Language) throws {
        id = try language.requireID()
        code = language.code
    }
}
