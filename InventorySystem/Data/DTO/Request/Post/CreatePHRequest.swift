import Foundation

struct CreatePHRequest: Codable {
    let username, email: String
    let factoryID: Int
}
