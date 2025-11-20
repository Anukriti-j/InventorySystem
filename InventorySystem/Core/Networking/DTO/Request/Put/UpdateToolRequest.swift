import Foundation

struct UpdateToolRequest: Codable {
    let name, description: String
    let categoryID: Int
    let imageFile, isPerishable, isExpensive: String
    let threshold: Int

    enum CodingKeys: String, CodingKey {
        case name, description
        case categoryID = "categoryId"
        case imageFile, isPerishable, isExpensive, threshold
    }
}
