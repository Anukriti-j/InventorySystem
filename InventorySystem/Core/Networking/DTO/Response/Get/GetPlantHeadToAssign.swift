import Foundation

struct GetPlantHeadToAssign: Codable {
    let success: Bool
    let message: String
    let data: [PlantHeadData]
}

struct PlantHeadData: Codable, Identifiable {
    let id: Int
    let username, isActive: String

    enum CodingKeys: String, CodingKey {
        case id = "plantheadId"
        case username, isActive
    }
}

