struct CreateFactoryResponse: Codable {
    let success: Bool
    let message: String
    let data: CreatedFactoryData?
}

struct CreatedFactoryData: Codable {
    let factoryId: Int
}
