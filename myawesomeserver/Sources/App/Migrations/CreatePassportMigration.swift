import Fluent

struct CreatePassportMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Passport.schema)
            .id()
            .field("passport_number", .string, .required)
            .field("person_id", .uuid, .required, .references(Person.schema, "id"))
            .unique(on: "person_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Passport.schema).delete()
    }
}
