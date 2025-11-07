import Foundation

struct GetUnassignedFactory: Codable {
    let success: Bool
    let message: String
    let data: [GetUnassignedFactoryData]
}

struct GetUnassignedFactoryData: Codable {
    let factoryID: Int
    let factoryName: String

    enum CodingKeys: String, CodingKey {
        case factoryID = "factoryId"
        case factoryName
    }
}
