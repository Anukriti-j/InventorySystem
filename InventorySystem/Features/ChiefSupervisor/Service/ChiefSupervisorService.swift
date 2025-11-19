import Foundation

final class ChiefSupervisorService {
    static let shared = ChiefSupervisorService()
    let pathBuilder = APIPathBuilder()
    private init() {}
    
    func addChiefSupervisor(request: CreateChiefRequest) async throws -> CreateChiefResponse {
        let data = try JSONEncoder().encode(request)
        let path = pathBuilder.buildPath("/owner/create/chiefsupervisor")
        let endpoint = APIEndpoint(
            path: path,
            method: .post,
            body: data,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: CreateChiefResponse.self)
    }
    
    func getSupervisor(factoryID: Int) async throws -> GetSupervisor {
        print("get supervisor called in service''")
        let path = pathBuilder.buildPath("/owner/factories/\(factoryID)/supervisors")
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetSupervisor.self)
    }
}
