import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}
    
    private let baseURL = "https://6909d18f1a446bb9cc202601.mockapi.io/username"
    
    func login() async throws -> [LoginResponse] {
        //let data = try JSONEncoder().encode(request)
        let endpoint = APIEndpoint(
            path: "\(baseURL)",
            method: .get
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: [LoginResponse].self)
    }
}
