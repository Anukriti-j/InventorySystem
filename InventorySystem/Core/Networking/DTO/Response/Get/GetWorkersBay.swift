import Foundation

struct GetWorkersBay: Codable {
    let success: Bool
    let message: String
    let data: [Bay]?
}

struct Bay: Codable, Identifiable {
    let id: Int
    let bayName: String
}
