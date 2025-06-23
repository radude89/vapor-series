import Fluent
import Foundation

final class MoodLog: Model, @unchecked Sendable {
    static let schema = "mood_logs"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "mood")
    var mood: String
    
    @OptionalField(key: "note")
    var note: String?
    
    @Field(key: "logged_at")
    var loggedAt: Date
    
    @Parent(key: "person_id")
    var person: Person
    
    init() {}
    
    init(
        id: UUID? = nil,
        personID: Person.IDValue,
        mood: String,
        note: String? = nil,
        loggedAt: Date = Date()
    ) {
        self.id = id
        self.$person.id = personID
        self.mood = mood
        self.note = note
        self.loggedAt = loggedAt
    }
}
