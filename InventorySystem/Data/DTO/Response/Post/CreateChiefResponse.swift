import Foundation

struct CreateChiefResponse: Codable {
    let success: Bool
    let message: String
    let data: CreateChiefResponseData
}

struct CreateChiefResponseData: Codable {
    let supervisorID: Int
    let name, email, factoryID, isActive: String

    enum CodingKeys: String, CodingKey {
        case supervisorID = "supervisorId"
        case name, email
        case factoryID = "factoryId"
        case isActive
    }
}
