import Foundation

protocol NetworkingProtocol {
    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async
    throws -> T
}

final class APIClient: NetworkingProtocol {
    static let shared = APIClient()
    private init() {}
    
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let request = try buildRequest(from: endpoint)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try validateResponse(data: data, response: response)
        
        return try decodeResponse(data: data, to: responseType)
    }
    
    private func buildRequest(from endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        request.allHTTPHeaderFields = endpoint.headers ?? [:]

        if let customContentType = endpoint.contentType {
            request.setValue(customContentType, forHTTPHeaderField: "Content-Type")
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if request.value(forHTTPHeaderField: "Accept") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        if endpoint.requiresAuth {
            guard let token = KeychainManager.shared.read() else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func validateResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            default:
                throw APIError.serverError(message: "HTTP \(httpResponse.statusCode)")
            }
            
            let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
            print("Server Error \(httpResponse.statusCode):", message)
            throw APIError.serverError(message: message)
        }
    }
    
    private func decodeResponse<T: Decodable>(data: Data, to type: T.Type) throws -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error:", error)
            throw APIError.decodingError
        }
    }
}
