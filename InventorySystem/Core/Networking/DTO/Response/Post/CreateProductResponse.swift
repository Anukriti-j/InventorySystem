import Foundation

struct CreateProductResponse: Codable {
    let success: Bool
    let message: String
    //let data: CreateProductResponseData
}

//struct CreateProductResponseData: Codable {
//    let id: Int
//    let name, productDescription: String
//    let price, rewardPoint: Int
//    let categoryName: String
//    let image: String
//    let isActive: String
//}
