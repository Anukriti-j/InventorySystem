import Foundation

struct GetAllWorkers: Codable {
    let success: Bool
    let message: String
    let data: [Worker]
    let pagination: Pagination
}

struct Worker: Codable, Identifiable {
    let id: Int
    let workerName, factoryName, location, bayArea: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case id = "workerId"
        case workerName, factoryName, location, bayArea, status
    }
}


