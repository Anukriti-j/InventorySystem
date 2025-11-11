import Foundation

struct GetAllFactories: Codable {
    let success: Bool
    let message: String
    let data: [Factory]
    let pagination: Pagination
}

struct Factory: Codable, Identifiable, Equatable {
    let id: Int
    let factoryName, location, plantHeadName: String
    let totalProducts: Int
    let totalTools: Int
    let totalWorkers: Int
    let status: String
    let chiefSupervisorName: String


    enum CodingKeys: String, CodingKey {
        case id = "factoryId"
        case factoryName, location, plantHeadName, totalProducts, totalTools, totalWorkers, status, chiefSupervisorName
    }
}
