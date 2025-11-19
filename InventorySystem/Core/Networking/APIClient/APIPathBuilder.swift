import Foundation

struct APIPathBuilder {
    let baseURL = APIConstants.baseURL
    
    func buildPath(
        _ endpoint: String,
        queryItems: [String: String?] = [:]
    ) -> String {
        var components = URLComponents(string: baseURL + endpoint)!
        components.queryItems = queryItems.compactMap { key, value in
            guard let value = value else { return nil }
            return URLQueryItem(name: key, value: value)
        }
        return components.string ?? baseURL + endpoint
    }
}
