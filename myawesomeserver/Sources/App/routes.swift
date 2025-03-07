import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    ContentConfiguration.global.use(decoder: decoder, for: .json)

    try app.register(collection: PersonsController())
}
