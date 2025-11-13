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
    ) async throws -> GetAllWorkers {
        print("fetching workers")
        let path = pathBuilder.buildPath(
            "/owner/worker/getall",
            queryItems: [
                "page": "\(page)",
                "size": "\(size)",
                "sortBy": sortBy,
                "sortDirection": sortDirection,
                "status": status
            ]
        )
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllWorkers.self)
    }
    
    func deleteWorker(workerID: Int) async throws -> DeleteWorkerResponse {
        let path = pathBuilder.buildPath("/owner/worker/delete/\(workerID)")
        let endpoint = APIEndpoint(
            path: path,
            method: .delete,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: DeleteWorkerResponse.self)
    }
}
