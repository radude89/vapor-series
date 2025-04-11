import Fluent

struct CreatePersonMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let eyeColor = try await database.enum("eye_color")
            .case(EyeColor.black.rawValue)
            .case(EyeColor.blue.rawValue)
            .case(EyeColor.other.rawValue)
            .create()

        try await database.schema(Person.schema)
            .id()
            .field("name", .string, .required)
            .field("date_of_birth", .date)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .field("eye_color", eyeColor)
            .field("is_active", .bool, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.enum("eye_color").delete()
        try await database.schema(Person.schema).delete()
    }
}
