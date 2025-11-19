import Foundation

struct ErrorResponseDTO: Codable {
    let success: Bool
    let message: String
    let data: ErrorDetailDTO?
}

struct ErrorDetailDTO: Codable {
    let error: String?
    let timestamp: String?
    let status: Int?
}
