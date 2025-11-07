import Foundation

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let data: LoginData
}

struct LoginData: Codable {
    let id: Int
    let username, email, token, role: String
}
