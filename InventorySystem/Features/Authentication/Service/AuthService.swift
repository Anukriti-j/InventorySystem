import Foundation

protocol Authentication {
    func login(request: LoginRequest) async throws -> LoginResponse
}

final class AuthService: Authentication {
    static let shared = AuthService()
    private init() {}
    
    func login(request: LoginRequest) async throws -> LoginResponse {
        let data = try JSONEncoder().encode(request)
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/auth/login",
            method: .post,
            body: data
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: LoginResponse.self)
    }
}
