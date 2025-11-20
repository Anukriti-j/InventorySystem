import Foundation

struct CreateOrUpdateMerchandiseRequest: Codable {
    let name: String
    let requiredPoints, availableQuantity: Int
    let image: String
}
