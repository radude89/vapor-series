import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) async throws {
    app.databases.use(.sqlite(.memory), as: .sqlite)
    app.migrations.add(
        CreatePersonMigration(),
        CreatePassportMigration()
    )
    try await app.autoMigrate()
    try routes(app)
}
