import Vapor

struct MoodLogResponseContent: Content {
    let id: UUID?
    let mood: String
    let note: String?
    let loggedAt: Date?
    
    init(id: UUID?, mood: String, note: String?, loggedAt: Date?) {
        self.id = id
        self.mood = mood
        self.note = note
        self.loggedAt = loggedAt
    }
}

// MARK: - Helpers

extension MoodLogResponseContent {
    init(moodLog: MoodLog) throws {
        id = try moodLog.requireID()
        mood = moodLog.mood
        note = moodLog.note
        loggedAt = moodLog.loggedAt
    }
}
