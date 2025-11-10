import Foundation

struct GetAllUsers: Codable {
    let success: Bool
    let message: String
    let data: [GetAllUsersData]
    let pagination: Pagination
}

struct GetAllUsersData: Codable {
    let id: Int
    let username, email, role, isActive: String
    let createdAt: String
}


