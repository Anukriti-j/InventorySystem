
import Foundation

struct GetSupervisor: Codable {
    let success: Bool
    let message: String
    let data: [GetSupervisorData]
}

struct GetSupervisorData: Codable, Identifiable {
    let id: Int
    let name, email, isActive: String

    enum CodingKeys: String, CodingKey {
        case id = "supervisorId"
        case name, email, isActive
    }
}
