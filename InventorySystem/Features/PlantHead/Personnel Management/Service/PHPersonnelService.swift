import Foundation

final class PHPersonnelService {
    static let shared = PHPersonnelService()
    private init() {}
    
    func addChiefSupervisor(request: CreateChiefRequest) async throws -> CreateChiefResponse {
        let data = try JSONEncoder().encode(request)
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/owner/create/chiefsupervisor",
            method: .post,
            body: data,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: CreateChiefResponse.self)
    }
    
    func getSupervisor(factoryID: Int) async throws -> GetSupervisor {
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/owner/factories/\(factoryID)/supervisors",
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetSupervisor.self)
    }
}
