import Foundation

struct GetAllPlantHeads: Codable {
    let success: Bool
    let message: String
    let data: [GetAllPlantHeadData]
}

struct GetAllPlantHeadData: Codable {
    let plantheadID: Int
    let username, isActive: String

    enum CodingKeys: String, CodingKey {
        case plantheadID = "plantheadId"
        case username, isActive
    }
}

