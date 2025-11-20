import Foundation

struct CreateFactoryRequest: Codable {
    let name, city, address: String
    let plantHeadId: Int?
}
