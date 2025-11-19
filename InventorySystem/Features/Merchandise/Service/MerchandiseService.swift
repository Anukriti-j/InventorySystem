import Foundation
import UIKit

final class MerchandiseService {
    static let shared = MerchandiseService()
    let pathBuilder = APIPathBuilder()
    private init() {}
    
    
    func fetchMerchandise(
        page: Int,
        size: Int,
        sortBy: String?,
        sortDirection: String?,
        search: String?,
        status: String?,
        stockStatus: String?
    ) async throws -> GetAllMerchandise {
        let path = pathBuilder.buildPath(
            "/owner/all/merchandise",
            queryItems: [
                "page": "\(page)",
                "size": "\(size)",
                "sortBy": sortBy,
                "sortDirection": sortDirection,
                "search": search,
                "status": status,
                "stockStatus": stockStatus
            ]
        )
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllMerchandise.self)
    }
    
    func deleteMerchandise(merchandiseId: Int) async throws -> DeleteMerchandiseResponse {
        let path = pathBuilder.buildPath("/owner/delete/merchandise/\(merchandiseId)")
        let endpoint = APIEndpoint(
            path: path,
            method: .delete,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: DeleteMerchandiseResponse.self)
    }
    
    func updateMerchandise(request: CreateOrUpdateMerchandiseRequest, image: UIImage?) async throws -> CreateOrUpdateMerchandiseResponse {
        let data = try JSONEncoder().encode(request)
        let path = pathBuilder.buildPath("/owner/update/merchandise")
        let boundary = UUID().uuidString
        var body = Data()

        body.appendFormField(named: "name", value: request.name, boundary: boundary)
        body.appendFormField(named: "requiredPoints", value: "\(request.requiredPoints)", boundary: boundary)
        body.appendFormField(named: "availabelQuantity", value: "\(request.availableQuantity)", boundary: boundary)
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.appendFileField(
                named: "imageFile",
                fileName: "merchandise.jpg",
                mimeType: "image/jpeg",
                fileData: imageData,
                boundary: boundary
            )
        }
        
        body.append("--\(boundary)--\r\n")
        
        let endpoint = APIEndpoint(
            path: path,
            method: .put,
            body: body,
            requiresAuth: true,
            contentType: "multipart/form-data; boundary=\(boundary)"
        )
        
        return try await APIClient.shared.request(endpoint: endpoint, responseType: CreateOrUpdateMerchandiseResponse.self)
    }
    
    func createMerchandise(request: CreateOrUpdateMerchandiseRequest, image: UIImage?) async throws -> CreateOrUpdateMerchandiseResponse {
        let path = pathBuilder.buildPath("/owner/add/merchandise")
        let boundary = UUID().uuidString
        var body = Data()

        body.appendFormField(named: "name", value: request.name, boundary: boundary)
        body.appendFormField(named: "requiredPoints", value: "\(request.requiredPoints)", boundary: boundary)
        body.appendFormField(named: "availableQuantity", value: "\(request.availableQuantity)", boundary: boundary)
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.appendFileField(
                named: "image",
                fileName: "merchandise.jpg",
                mimeType: "image/jpeg",
                fileData: imageData,
                boundary: boundary
            )
        }
        
        body.append("--\(boundary)--\r\n")
        
        let endpoint = APIEndpoint(
            path: path,
            method: .post,
            body: body,
            requiresAuth: true,
            contentType: "multipart/form-data; boundary=\(boundary)"
        )
        
        return try await APIClient.shared.request(endpoint: endpoint, responseType: CreateOrUpdateMerchandiseResponse.self)
    }

}
