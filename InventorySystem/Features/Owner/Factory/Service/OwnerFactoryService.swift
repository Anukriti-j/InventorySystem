import Foundation

final class OwnerFactoryService {
    static let shared = OwnerFactoryService()
    
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
    
    func getAllPlantHeads() async throws -> GetAllPlantHeads {
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/owner/plantheads",
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllPlantHeads.self)
    }
}
