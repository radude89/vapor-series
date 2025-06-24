import Fluent

struct CreatePersonLanguageMigration: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema(PersonLanguage.schema)
            .id()
            .field("person_id", .uuid, .required, .references(Person.schema, "id", onDelete: .cascade))
            .field("language_id", .uuid, .required, .references(Language.schema, "id", onDelete: .cascade))
            .field("date_learnt", .datetime)
            .field("is_primary", .bool)
            .unique(on: "person_id", "language_id")
            .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema(PersonLanguage.schema).delete()
    }
}
