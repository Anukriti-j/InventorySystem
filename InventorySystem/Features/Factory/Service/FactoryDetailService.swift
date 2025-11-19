import Foundation

final class FactoryDetailService {
    static let shared = FactoryDetailService()
    let pathBuilder = APIPathBuilder()
    private init() {}
    
    func fetchFactoryWorkers(
        page: Int,
        size: Int,
        sortBy: String?,
        sortDirection: String?,
        search: String?,
        status: String?,
        factoryId: Int
    ) async throws -> GetAllWorkers {
        let path = pathBuilder.buildPath(
            "owner/worker/getall",
            queryItems: [
                "page": "\(page)",
                "size": "\(size)",
                "sortBy": sortBy,
                "sortDirection": sortDirection,
                "search": search,
                "status": status,
                "factoryId": "\(factoryId)"
            ]
        )
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllWorkers.self)
    }
    
    func fetchFactoryTools(
        page: Int,
        size: Int,
        sortBy: String?,
        sortDirection: String?,
        search: String?,
        status: String?
    ) async throws -> GetAllTools {
        let path = pathBuilder.buildPath(
            "",
            queryItems: [
                "page": "\(page)",
                "size": "\(size)",
                "sortBy": sortBy,
                "sortDirection": sortDirection,
                "search": search,
                "status": status
            ]
        )
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllTools.self)
    }
    
    func fetchFactoryProducts(
        page: Int,
        size: Int,
        sortBy: String?,
        sortDirection: String?,
        search: String?,
        status: String?
    ) async throws -> GetAllProducts {
        let path = pathBuilder.buildPath(
            "",
            queryItems: [
                "page": "\(page)",
                "size": "\(size)",
                "sortBy": sortBy,
                "sortDirection": sortDirection,
                "search": search,
                "status": status
            ]
        )
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllProducts.self)
    }
}
