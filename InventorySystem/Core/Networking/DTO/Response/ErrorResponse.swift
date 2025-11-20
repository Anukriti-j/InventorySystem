import Foundation

struct UnifiedErrorResponse: Decodable {
    let success: Bool?
    let message: String?
    
    let errorCode: String?
    let statusCode: Int?
    
    let data: OldErrorData?
    
    struct OldErrorData: Decodable {
        let error: String?
        let timestamp: String?
        let status: Int?
    }
    
    var readableMessage: String {
        if let msg = message, !msg.isEmpty { return msg }
        if let msg = data?.error, !msg.isEmpty { return msg }
        return APIError.unknown.errorDescription ?? "Error"
    }
    
    var readableStatus: Int? {
        if let code = statusCode { return code }
        if let code = data?.status { return code }
        return nil
    }
}
