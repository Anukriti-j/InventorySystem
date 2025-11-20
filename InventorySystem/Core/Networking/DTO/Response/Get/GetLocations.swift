import Foundation

struct GetLocations: Codable {
    let success: Bool
    let message: String
    let data: [String]
}
