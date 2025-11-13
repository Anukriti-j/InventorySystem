import Foundation
import SwiftUI

final class OwnerToolService {
    static let shared = OwnerToolService()
    let pathBuilder = APIPathBuilder()
    
    private init() {}
    
    func fetchTools(
            factoryId: Int? = nil,
            categoryNames: String? = nil,          // comma-separated
            availability: String? = nil,           // InStock / OutOfStock
            page: Int,
            size: Int,
            sortBy: String? = nil,
            sortDir: String? = nil,
            search: String? = nil
        ) async throws -> GetAllTools {

            let queryItems: [String: String?] = [
                "factoryId": factoryId.map { "\($0)" },
                "categoryNames": categoryNames,
                "availability": availability,
                "page": "\(page)",
                "size": "\(size)",
                "sortBy": sortBy,
                "sortDir": sortDir,
                "search": search
            ]

            let path = pathBuilder.buildPath("/tools/getAll", queryItems: queryItems)
            let endpoint = APIEndpoint(path: path, method: .get, requiresAuth: true)

            return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllTools.self)
        }
    
    func deleteTool(toolID: Int) async throws -> DeleteToolResponse {
        let path = pathBuilder.buildPath("/tools/delete/\(toolID)")
        
        let endpoint = APIEndpoint(
            path: path,
            method: .delete,
            requiresAuth: true
        )
        
        return try await APIClient.shared.request(endpoint: endpoint, responseType: DeleteToolResponse.self)
    }
    
    func createTool(request: CreateToolRequest, image: UIImage?) async throws -> CreateToolResponse {
        print("Sending request:", request)
        print("Image attached:", image != nil)
        
        let path = pathBuilder.buildPath("/tools/create")
        let boundary = UUID().uuidString
        var body = Data()
        
        body.appendFormField(named: "name", value: request.name, boundary: boundary)
        body.appendFormField(named: "description", value: request.description, boundary: boundary)
        if let categoryId = request.categoryID {
            body.appendFormField(named: "categoryId", value: String(categoryId), boundary: boundary)
        }
        
        if let newCategory = request.newCategoryName, !newCategory.isEmpty {
            body.appendFormField(named: "newCategoryName", value: newCategory, boundary: boundary)
        }
        body.appendFormField(named: "isPerishable", value: request.isPerishable, boundary: boundary)
        body.appendFormField(named: "isExpensive", value: request.isExpensive, boundary: boundary)
        body.appendFormField(named: "threshold", value: String(request.threshold), boundary: boundary)
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.appendFileField(
                named: "imageFile",
                fileName: "tool.jpg",
                mimeType: "image/jpeg",
                fileData: imageData,
                boundary: boundary
            )
        }
        
        // End of multipart
        body.append("--\(boundary)--\r\n")
        
        // Build endpoint
        let endpoint = APIEndpoint(
            path: path,
            method: .post,
            body: body,
            requiresAuth: true,
            contentType: "multipart/form-data; boundary=\(boundary)"
        )
        
        // Send request
        let response = try await APIClient.shared.request(endpoint: endpoint, responseType: CreateToolResponse.self)
        
        print("Tool created successfully:", response)
        return response
    }
    
    func getCategories() async throws -> GetToolCategories {
        let endpoint = APIEndpoint(
            path: "\(APIConstants.baseURL)/tools/category/all",
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetToolCategories.self)
    }
    
    func updateTool(toolId: Int, request: UpdateToolRequest, image: UIImage?) async throws -> UpdateToolResponse {
        print("🔧 Updating Tool ID:", toolId)
        print("Sending request:", request)
        print("Image attached:", image != nil)
        
        // API path
        let path = pathBuilder.buildPath("/tools/update/\(toolId)")
        
        // Create multipart body
        let boundary = UUID().uuidString
        var body = Data()
        
        body.appendFormField(named: "name", value: request.name, boundary: boundary)
        body.appendFormField(named: "description", value: request.description, boundary: boundary)
        body.appendFormField(named: "categoryId", value: String(request.categoryID), boundary: boundary)
        body.appendFormField(named: "isPerishable", value: request.isPerishable, boundary: boundary)
        body.appendFormField(named: "isExpensive", value: request.isExpensive, boundary: boundary)
        body.appendFormField(named: "threshold", value: String(request.threshold), boundary: boundary)
        body.appendFormField(named: "availableQuantity", value: String(request.availableQuantity), boundary: boundary)
        
        // Append image if user updated it
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.appendFileField(
                named: "imageFile",
                fileName: "tool.jpg",
                mimeType: "image/jpeg",
                fileData: imageData,
                boundary: boundary
            )
        }
        
        // End of multipart form
        body.append("--\(boundary)--\r\n")
        
        let endpoint = APIEndpoint(
            path: path,
            method: .put,
            body: body,
            requiresAuth: true,
            contentType: "multipart/form-data; boundary=\(boundary)"
        )
        
        let response = try await APIClient.shared.request(endpoint: endpoint, responseType: UpdateToolResponse.self)
        
        print("Tool updated successfully:", response)
        return response
    }
}

