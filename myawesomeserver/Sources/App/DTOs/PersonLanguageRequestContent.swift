import Vapor

struct PersonLanguageRequestContent: Content {
    let code: String
    let isPrimary: Bool
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(String.self, forKey: .code)
        self.isPrimary = try container.decodeIfPresent(Bool.self, forKey: .isPrimary) ?? false
    }
}
