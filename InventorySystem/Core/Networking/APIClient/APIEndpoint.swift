import Foundation

struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let body: Data?
    let requiresAuth: Bool
    let contentType: String?
    
    init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil,
        requiresAuth: Bool = false,
        contentType: String? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.requiresAuth = requiresAuth
        self.contentType = contentType
    }
}
