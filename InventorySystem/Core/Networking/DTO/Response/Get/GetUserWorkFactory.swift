import Foundation

struct GetUserWorkFactory: Codable {
    let success: Bool
    let message: String
    let data: WorkFactory
}

struct WorkFactory: Codable {
    let factoryID: Int

    enum CodingKeys: String, CodingKey {
        case factoryID = "factoryId"
    }
}
