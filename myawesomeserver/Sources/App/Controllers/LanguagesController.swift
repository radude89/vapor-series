import Vapor
import Fluent

struct LanguagesController: RouteCollection, Sendable {
    func boot(routes: any RoutesBuilder) throws {
        let languages = routes.grouped("languages")
        
        // CREATE
        languages.post { request in
            try await createLanguage(request: request)
        }
        
        // READ
        languages.get { request in
            try await getLanguages(request: request)
        }
        
        languages.get(":id") { request in
            try await getLanguage(request: request)
        }
        
        // UPDATE
        languages.put(":id") { request in
            try await updateLanguage(request: request)
        }
        
        // DELETE
        languages.delete(":id") { request in
            try await delete(Language.self, request: request)
        }
    }
}

// MARK: - Create

private extension LanguagesController {
    func createLanguage(request: Request) async throws -> LanguageResponseContent {
        let requestContent = try request.content.decode(LanguageRequestContent.self)
        let language = Language(code: requestContent.code)
        try await language.create(on: request.db)
        return try LanguageResponseContent(language: language)
    }
}

// MARK: - Read

private extension LanguagesController {
    func getLanguages(request: Request) async throws -> [LanguageResponseContent] {
        try await Language.query(on: request.db)
            .all()
            .map(LanguageResponseContent.init(language:))
    }
    
    func getLanguage(request: Request) async throws -> LanguageResponseContent {
        let language: Language = try await findByID(request: request)
        return try LanguageResponseContent(language: language)
    }
}

// MARK: - Update

private extension LanguagesController {
    func updateLanguage(request: Request) async throws -> LanguageResponseContent {
        let language: Language = try await findByID(request: request)
        let requestContent = try request.content.decode(LanguageRequestContent.self)
        
        language.setValue(requestContent.code, to: \.code)
        
        try await language.update(on: request.db)
        
        return try LanguageResponseContent(language: language)
    }
}
