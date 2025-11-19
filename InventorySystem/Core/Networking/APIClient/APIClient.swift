import Foundation

protocol NetworkingProtocol {
    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T
}

final class APIClient: NetworkingProtocol {
    static let shared = APIClient()
    private init() {}
    
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let request = try buildRequest(from: endpoint)
        
        LoggerInterceptor.logRequest(request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        LoggerInterceptor.logResponse(data: data, response: response)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
                if let errorDTO = try? JSONDecoder().decode(ErrorResponseDTO.self, from: data) {
                    throw APIError.serverError(message: errorDTO.message)
                }
                throw APIError.serverError(message: "Unexpected server error")
            }
        
        do {
            let decoded = try JSONDecoder().decode(responseType, from: data)
            return decoded
        } catch {
            print("Decoding error:", error)
            throw APIError.decodingError
        }
    }
    
    private func buildRequest(from endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.allHTTPHeaderFields = endpoint.headers ?? [:]
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let customContentType = endpoint.contentType {
            request.setValue(customContentType, forHTTPHeaderField: "Content-Type")
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if endpoint.requiresAuth {
            guard let token = KeychainManager.shared.read() else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
