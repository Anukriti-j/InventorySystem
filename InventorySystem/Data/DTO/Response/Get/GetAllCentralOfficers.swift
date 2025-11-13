import Foundation

struct GetAllCentralOfficers: Codable {
    let success: Bool
    let message: String
    let data: [CentralOfficer]
    let pagination: Pagination
}

struct CentralOfficer: Codable, Identifiable {
    let id: Int
    let username, email, role, isActive: String
    let createdAt: String
}
