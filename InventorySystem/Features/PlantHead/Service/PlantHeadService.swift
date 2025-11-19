import Foundation

@Observable
final class PlantHeadService {
    static let shared = PlantHeadService()
    let pathBuilder = APIPathBuilder()
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
    
    func fetchPlantHeads(
        page: Int,
        size: Int,
        role: String,
        sortBy: String?,
        sortDirection: String?,
        name: String?,
        statuses: String?,
    ) async throws -> GetAllPlantHeads {
        let path = pathBuilder.buildPath(
            "/owner/users",
            queryItems: [
                "page": "\(page)",
                "size": "\(size)",
                "role": role.uppercased(),
                "sortBy": sortBy,
                "sortDirection": sortDirection,
                "name": name,
                "statuses": statuses
            ]
        )
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllPlantHeads.self)
    }
    
    func getAllPlantHeads() async throws -> GetPlantHeadToAssign {
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/owner/plantheads",
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetPlantHeadToAssign.self)
    }
    
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
