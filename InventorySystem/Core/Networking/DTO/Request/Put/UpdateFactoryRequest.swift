import Foundation

struct UpdateFactoryRequest: Codable {
    let id: Int
    let name, city, address: String
    let plantHeadID: Int

    enum CodingKeys: String, CodingKey {
        case id, name, city, address
        case plantHeadID = "plantHeadId"
    }
}
