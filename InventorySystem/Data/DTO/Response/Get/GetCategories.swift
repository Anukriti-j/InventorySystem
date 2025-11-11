import Foundation

struct GetCategories: Codable {
    let success: Bool
    let message: String
    let data: [Category]
}

struct Category: Codable, Identifiable {
    let id: Int
    let categoryName, categoryDescription: String
}
