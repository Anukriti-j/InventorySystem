import Foundation

protocol FactoryServiceProtocol {
    func fetchFactories(
        page: Int,
        size: Int,
        sortBy: String?,
        sortDirection: String?,
        search: String?,
        status: String?,
        location: String?
    ) async throws -> GetAllFactories
}


final class FactoryService: FactoryServiceProtocol {
    static let shared = FactoryService()
    private let pathBuilder = APIPathBuilder()
    
    private init() {}
    
    func createFactory(request: CreateFactoryRequest) async throws -> CreateFactoryResponse {
        let data = try JSONEncoder().encode(request)
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/owner/create-factory",
            method: .post,
            body: data,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: CreateFactoryResponse.self)
    }
    
    func fetchFactories(
        page: Int,
        size: Int,
        sortBy: String?,
        sortDirection: String?,
        search: String?,
        status: String?,
        location: String?
    ) async throws -> GetAllFactories {
        let path = pathBuilder.buildPath(
            "/owner/factories",
            queryItems: [
                "page": "\(page)",
                "size": "\(size)",
                "sortBy": sortBy,
                "sortDirection": sortDirection,
                "search": search,
                "status": status,
                "location": location
            ]
        )
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllFactories.self)
    }
    
    func deleteFactory(factoryID: Int) async throws -> DeleteFactoryResponse {
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/owner/factories/\(factoryID)/delete",
            method: .delete,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: DeleteFactoryResponse.self)
    }
    
    func updateFactory(request: UpdateFactoryRequest) async throws -> UpdateFactoryResponse {
        let data = try JSONEncoder().encode(request)
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/owner/factory/update",
            method: .put,
            body: data,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: UpdateFactoryResponse.self)
    }
    
    func GetFactoryForUser(userId: Int) async throws -> GetUserWorkFactory {
        let path = pathBuilder.buildPath("/owner/users/\(userId)/factory-id")
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetUserWorkFactory.self)
    }
}
