import Fluent

struct CreateLanguageMigration: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema(Language.schema)
            .id()
            .field("code", .string, .required)
            .unique(on: "code")
            .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema(Language.schema).delete()
    }
}
