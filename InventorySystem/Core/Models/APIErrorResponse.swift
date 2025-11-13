import Foundation

struct APIErrorResponse: Codable {
    let success: Bool?
    let message: String
}
