import Foundation

struct CreateChiefRequest: Codable {
    let name, email: String
    let factoryID: Int
    
    enum CodingKeys: String, CodingKey {
        case name, email
        case factoryID = "factoryId"
    }
}
