import Foundation

struct CreatePHResponse: Codable {
    let success: Bool
    let message: String
    let data: CreatedPHData?
}

struct CreatedPHData: Codable {
    let plantheadID: Int

    enum CodingKeys: String, CodingKey {
        case plantheadID = "plantheadId"
    }
}
