import Foundation

struct UpdateFactoryResponse: Codable {
    let success: Bool
    let message: String
    let data: UpdatedFactoryStatus
}

struct UpdatedFactoryStatus: Codable {
    let error, timestamp: String
    let status: Int
}
