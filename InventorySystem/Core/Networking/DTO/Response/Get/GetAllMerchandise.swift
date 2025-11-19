import Foundation

struct GetAllMerchandise: Codable {
    let success: Bool
    let message: String
    let data: [Merchandise]
    let pagination: Pagination
}

struct Merchandise: Codable, Identifiable {
    let id: Int
    let name: String
    let requiredPoints, availableQuantity: Int
    let imageURL: String
    let stockStatus, status: String

    enum CodingKeys: String, CodingKey {
        case id, name, requiredPoints, availableQuantity
        case imageURL = "imageUrl"
        case stockStatus, status
    }
}
