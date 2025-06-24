import Vapor
import Fluent

struct MoodLogsController: RouteCollection, Sendable {
    func boot(routes: any RoutesBuilder) throws {
        let moodLogs = routes.grouped("moodlogs")
        
        // READ
        moodLogs.get { request in
            try await getAllMoods(request: request)
        }
        
        moodLogs.get(":id") { request in
            try await getMoodLog(request: request)
        }
        
        // UPDATE
        moodLogs.put(":id") { request in
            try await updateMoodLog(request: request)
        }
        
        // DELETE
        moodLogs.delete(":id") { request in
            try await delete(MoodLog.self, request: request)
        }
    }
}

// MARK: - Read

private extension MoodLogsController {
    func getAllMoods(request: Request) async throws -> [MoodLogResponseContent] {
        try await MoodLog.query(on: request.db).all().map { moodLog in
            try MoodLogResponseContent(moodLog: moodLog)
        }
    }
    
    func getMoodLog(request: Request) async throws -> MoodLogResponseContent {
        let moodLog: MoodLog = try await findByID(request: request)
        return try MoodLogResponseContent(moodLog: moodLog)
    }
}

// MARK: - Update

private extension MoodLogsController {
    func updateMoodLog(request: Request) async throws -> MoodLogResponseContent {
        let moodLog: MoodLog = try await findByID(request: request)
        
        let requestContent = try request.content.decode(MoodLogRequestContent.self)
        moodLog.setValue(requestContent.mood, to: \.mood)
        moodLog.setValue(requestContent.note, to: \.note)
        try await moodLog.update(on: request.db)
        
        return try MoodLogResponseContent(moodLog: moodLog)
    }
}
