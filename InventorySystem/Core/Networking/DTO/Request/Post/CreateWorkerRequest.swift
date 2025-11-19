import Foundation

struct CreateWorkerRequest: Codable {
    let factoryID: Int
    let name, email: String
    let bayID: Int
    let image: String

    enum CodingKeys: String, CodingKey {
        case factoryID = "factoryId"
        case name, email
        case bayID = "bayId"
        case image
    }
}
