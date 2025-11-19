import Foundation

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let data: LoginDataOrError?
}

struct LoginData: Codable {
    let id: Int
    let username, email, token, role: String
}

struct APIErrorData: Codable {
    let error: String
    let timestamp: String?
    let status: Int?
}

enum LoginDataOrError: Codable {
    case success(LoginData)
    case failure(APIErrorData)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let loginData = try? container.decode(LoginData.self) {
            self = .success(loginData)
        } else if let errorData = try? container.decode(APIErrorData.self) {
            self = .failure(errorData)
        } else {
            throw DecodingError.typeMismatch(
                LoginDataOrError.self,
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Unknown data format in response")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .success(let data):
            try data.encode(to: encoder)
        case .failure(let errorData):
            try errorData.encode(to: encoder)
        }
    }
}








