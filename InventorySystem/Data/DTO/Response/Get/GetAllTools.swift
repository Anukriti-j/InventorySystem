import Foundation

struct GetAllTools: Codable {
    let success: Bool
    let message: String
    let data: [Tool]
    let pagination: Pagination
}

struct Tool: Codable, Identifiable {
    let id: Int
    let name, description, categoryName: String
    let imageURL: String
    let isPerishable, isExpensive: String
    let threshold, availableQuantity: Int
    let status, stockStatus, createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, categoryName
        case imageURL = "imageUrl"
        case isPerishable, isExpensive, threshold, availableQuantity, status, stockStatus, createdAt, updatedAt
    }
}
