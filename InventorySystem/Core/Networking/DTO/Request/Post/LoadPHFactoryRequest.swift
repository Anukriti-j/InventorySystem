import Foundation

struct LoadPHFactoryRequest: Codable {
    let plantHeadID: Int

    enum CodingKeys: String, CodingKey {
        case plantHeadID = "plantHeadId"
    }
}
