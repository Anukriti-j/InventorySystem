import Foundation

struct LoggerInterceptor {
    
    static func logRequest(_ request: URLRequest) {
        print("\n REQUEST")
        
        if let method = request.httpMethod, let url = request.url?.absoluteString {
            print("[\(method)] \(url)")
        }
        
        if let headers = request.allHTTPHeaderFields {
            print("Headers:", headers)
        }
        
        if let body = request.httpBody,
           let json = String(data: body, encoding: .utf8) {
            print("Body:", json)
        } else {
            print("Body: <empty>")
        }
    }
    
    static func logResponse(data: Data, response: URLResponse) {
        print("\n RESPONSE ")
        
        if let http = response as? HTTPURLResponse {
            print("Status Code:", http.statusCode)
        }
        
        let body = String(data: data, encoding: .utf8) ?? "<Invalid Data>"
        print("Response Body:", body)
        print("====================================================\n")
    }
}
