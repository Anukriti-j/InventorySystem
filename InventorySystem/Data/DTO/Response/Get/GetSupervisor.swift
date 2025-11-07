
import Foundation

struct GetSupervisor: Codable {
    let success: Bool
    let message: String
    let data: GetSupervisorData
}

struct GetSupervisorData: Codable {
    let supervisorID: Int
    let name, email, isActive: String

    enum CodingKeys: String, CodingKey {
        case supervisorID = "supervisorId"
        case name, email, isActive
    }
}
