import Vapor
import Fluent

extension RouteCollection {
    func findByID<M: Model>(
        request: Request,
        idParamName: String = "id"
    ) async throws -> M where M.IDValue: LosslessStringConvertible {
        let id: M.IDValue? = request.parameters.get(idParamName)
        
        guard let object = try await M.find(
            id,
            on: request.db
        ) else {
            throw Abort(.notFound)
        }
        
        return object
    }
    
    func delete<M: Model>(
        _ type: M.Type,
        request: Request,
        idParamName: String = "id"
    ) async throws -> HTTPStatus where M.IDValue: LosslessStringConvertible {
        let object: M = try await findByID(
            request: request,
            idParamName: idParamName
        )

        try await object.delete(on: request.db)

        return HTTPStatus.noContent
    }
}
