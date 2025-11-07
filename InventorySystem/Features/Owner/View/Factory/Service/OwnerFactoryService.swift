import Foundation

final class OwnerFactoryService {
    static let shared = OwnerFactoryService()
    
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
}
