import Foundation

struct CreateProductRequest: Codable {
    let name, productDescription: String
    let categoryID: Int?
    let newCategoryName: String?
    let price: Double
    let imageFile: String

    enum CodingKeys: String, CodingKey {
        case name, productDescription
        case categoryID = "categoryId"
        case newCategoryName, price, imageFile
    }
}

