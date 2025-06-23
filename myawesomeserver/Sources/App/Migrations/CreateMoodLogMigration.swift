import Fluent

struct CreateMoodLogMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(MoodLog.schema)
            .id()
            .field("mood", .string, .required)
            .field("note", .string)
            .field("logged_at", .datetime, .required)
            .field("person_id", .uuid, .required, .references(Person.schema, "id"))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(MoodLog.schema).delete()
    }
}
