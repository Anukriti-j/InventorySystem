import Foundation

struct GetProductCategories: Codable {
    let success: Bool
    let message: String
    let data: [ProductCategory]
}

struct ProductCategory: Codable, Identifiable {
    let id: Int
    let categoryName: String

    enum CodingKeys: String, CodingKey {
        case id = "categoryId"
        case categoryName
    }
}
