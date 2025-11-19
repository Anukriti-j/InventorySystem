import Foundation

struct GetAllWorkers: Codable {
    let success: Bool
    let message: String
    let data: [Worker]
    let pagination: Pagination
}

struct Worker: Codable, Identifiable {
    let id: Int
    let workerName: String
    let factoryName: String?
    let factoryID: Int?
    let location, bayArea, status: String
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id = "workerId"
        case workerName, factoryName
        case factoryID = "factoryId"
        case location, bayArea, status, profileImage
    }
}
