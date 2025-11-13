import Foundation

struct GetToolCategories: Codable {
    let success: Bool
    let message: String
    let data: [ToolCategory]
}

struct ToolCategory: Codable, Identifiable {
    let id: Int
    let categoryName, categoryDescription: String
}
