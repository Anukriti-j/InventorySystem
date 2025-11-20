import Foundation

struct CreatePlantHeadRequest: Codable {
    let username, email: String
    let factoryId: Int?
}
