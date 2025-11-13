import Foundation

struct GetAllPlantHeads: Codable {
    let success: Bool
    let message: String
    let data: [PlantHead]
    let pagination: Pagination
}

struct PlantHead: Codable, Identifiable {
    let id: Int
    let username, email, role, isActive: String
    let createdAt: String
}
