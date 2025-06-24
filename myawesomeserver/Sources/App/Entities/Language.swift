import Fluent
import Foundation

final class Language: Model, @unchecked Sendable {
    static let schema = "languages"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "code")
    var code: String
    
    @Siblings(
        through: PersonLanguage.self,
        from: \.$language,
        to: \.$person
    )
    var persons: [Person]
    
    init() {}
    
    init(code: String) {
        self.code = code
    }
}
