import Foundation

struct LoadPHFactoryResponse: Codable {
    let success: Bool
    let message: String
    let data: [LoadPHFactoryResponseData]
}

struct LoadPHFactoryResponseData: Codable {
    let factoryID: Int
    let factoryName, factoryLocation: String

    enum CodingKeys: String, CodingKey {
        case factoryID = "factoryId"
        case factoryName, factoryLocation
    }
}
