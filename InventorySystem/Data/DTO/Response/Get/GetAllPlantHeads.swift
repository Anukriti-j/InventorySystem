import Foundation

struct GetAllPlantHeads: Codable {
    let success: Bool
    let message: String
    let data: [GetAllPlantHeadData]
}

struct GetAllPlantHeadData: Codable, Identifiable {
    let id: Int
    let username, isActive: String

    enum CodingKeys: String, CodingKey {
        case id = "plantheadId"
        case username, isActive
    }
}

