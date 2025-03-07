import Vapor

struct Person: Content, Identifiable {
    let id: UUID
    let name: String
    let dateOfBirth: Date?
}

extension Person {
    init(name: String, dateOfBirth: Date?) {
        id = UUID()
        self.name = name
        self.dateOfBirth = dateOfBirth
    }
}
