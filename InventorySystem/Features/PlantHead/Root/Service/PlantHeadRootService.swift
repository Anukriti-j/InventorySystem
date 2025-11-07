import Foundation

final class PlantHeadRootService {
    static let shared = PlantHeadRootService()
    private init() {}
    
    func loadPHFactories(request: LoadPHFactoryRequest) async throws -> LoadPHFactoryResponse {
        let data = try JSONEncoder().encode(request)
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/owner/planthead/factories",
            method: .post,
            body: data,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: LoadPHFactoryResponse.self)
    }
}
