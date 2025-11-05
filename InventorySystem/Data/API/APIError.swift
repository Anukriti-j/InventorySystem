import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case unauthorized
    case notFound
    case invalidData
    case serverError(message: String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid request URL."
        case .invalidResponse: return "Invalid response from server."
        case .decodingError: return "Failed to parse response data."
        case .unauthorized: return "Unauthorized request."
        case .notFound: return "Resource not found."
        case .serverError(let message): return message
        case .unknown: return "An unknown error occurred."
        case .invalidData:
            return "Data is invalid"
        }
    }
}
