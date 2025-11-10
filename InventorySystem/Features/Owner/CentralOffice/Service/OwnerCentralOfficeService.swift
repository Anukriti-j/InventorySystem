import Foundation

final class OwnerCentralOfficeService {
    static let shared = OwnerCentralOfficeService()
    
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
    
    func fetchCentralOfficer() {
        
    }
    
    func deleteCentralOfficer(id: Int) {
        
    }
}
