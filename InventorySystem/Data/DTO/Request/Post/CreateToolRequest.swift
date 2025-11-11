import Foundation

struct CreateToolRequest: Codable {
    let name, description: String
    let categoryID: Int?
    let newCategoryName: String?
    let imageFile, isPerishable, isExpensive: String
    let threshold: Int

    enum CodingKeys: String, CodingKey {
        case name, description
        case categoryID = "categoryId"
        case newCategoryName, imageFile, isPerishable, isExpensive, threshold
    }
}
