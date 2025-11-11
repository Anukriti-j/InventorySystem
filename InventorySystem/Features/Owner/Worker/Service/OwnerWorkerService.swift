import Foundation

final class OwnerWorkerService {
    static let shared = OwnerWorkerService()
    let pathBuilder = APIPathBuilder()
    
    func fetchWorkers(
        page: Int,
        size: Int,
        sortBy: String?,
        sortDirection: String?,
        status: String?,
        location: String?
    ) async throws -> GetAllWorkers {
        let path = pathBuilder.buildPath(
            "/owner/allworkers",
            queryItems: [
                "page": "\(page)",
                "size": "\(size)",
                "sortBy": sortBy,
                "sortDirection": sortDirection,
                "status": status,
                "location": location
                
            ]
        )
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllWorkers.self)
    }
}
