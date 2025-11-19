import Foundation

struct GetAllProducts: Codable {
    let success: Bool
    let message: String
    let data: [Product]
    let pagination: Pagination
}

struct Product: Codable, Identifiable {
    let id: Int
    let name, productDescription: String
    let price: Double
    let rewardPoint: Int
    let categoryName: String
    let image: String?
    let isActive: String
    let quantity: Int
    let stockStatus: String
}
