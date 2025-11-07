import Foundation

@Observable
final class OwnerPHService {
    static let shared = OwnerPHService()
    private init() {}
    
    func createPlantHead(request: CreatePHRequest) async throws -> CreatePHResponse {
        let data = try JSONEncoder().encode(request)
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/owner/create-planthead",
            method: .post,
            body: data,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: CreatePHResponse.self)
    }
    
    func getUnassignedFactory() async throws -> GetUnassignedFactory {
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/owner/unassigned",
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetUnassignedFactory.self)
    }
}
