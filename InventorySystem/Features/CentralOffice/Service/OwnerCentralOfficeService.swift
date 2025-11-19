import Foundation

final class CentralOfficeService {
    static let shared = CentralOfficeService()
    let pathBuilder = APIPathBuilder()
    private init() {}
    
    func createCentralOfficer(request: CreateCORequest) async throws -> CreateCOResponse {
        let data = try JSONEncoder().encode(request)
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/owner/add-central-officer",
            method: .post,
            body: data,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: CreateCOResponse.self)
    }
    
    func fetchCentralOfficer(
        page: Int,
        size: Int,
        role: String,
        sortBy: String?,
        sortDirection: String?,
        search: String?,
        statuses: String?,
    ) async throws -> GetAllCentralOfficers {
        let path = pathBuilder.buildPath(
            "/owner/users",
            queryItems: [
                "page": "\(page)",
                "size": "\(size)",
                "role": role.uppercased(),
                "sortBy": sortBy,
                "sortDirection": sortDirection,
                "name": search,
                "statuses": statuses
            ]
        )
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllCentralOfficers.self)
    }
    
    func deleteCentralOfficer(id: Int) async throws -> DeleteCentralOfficerResponse {
        let path = pathBuilder.buildPath("/owner/soft-delete/central-officer/\(id)")
        let endpoint = APIEndpoint(
            path: path,
            method: .delete,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: DeleteCentralOfficerResponse.self)
    }
}

