import Foundation

struct Pagination: Codable {
    let page, size, totalElements, totalPages: Int
}
