import Vapor

struct MoodLogRequestContent: Content {
    let mood: String
    let note: String?
}
