import Foundation
import SwiftUI

final class OwnerProductService {
    static let shared = OwnerProductService()
    private let pathBuilder = APIPathBuilder()
    private init() {}

    // MARK: - Fetch Products
    func fetchProducts(
        factoryId: Int? = nil,
        categoryNames: String? = nil,
        availability: String? = nil,
        page: Int,
        size: Int,
        sortBy: String? = nil,
        sortDir: String? = nil,
        search: String? = nil
    ) async throws -> GetAllProducts {
        let queryItems: [String: String?] = [
            "factoryId": factoryId.map(String.init),
            "categoryNames": categoryNames,
            "availability": availability,
            "page": "\(page)",
            "size": "\(size)",
            "sortBy": sortBy,
            "sortDir": sortDir,
            "search": search
        ]
        let path = pathBuilder.buildPath("/product/getAllProducts", queryItems: queryItems)
        let endpoint = APIEndpoint(path: path, method: .get, requiresAuth: true)
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllProducts.self)
    }

    func createProduct(request: CreateProductRequest, image: UIImage?) async throws -> CreateProductResponse {
        print("Sending request:", request)
        print("Image attached:", image != nil)
        
        let path = pathBuilder.buildPath("/product/create")
        let boundary = UUID().uuidString
        var body = Data()
        
        body.appendFormField(named: "name", value: request.name, boundary: boundary)
        if let categoryId = request.categoryID {
            body.appendFormField(named: "categoryId", value: String(categoryId), boundary: boundary)
        }
        
        if let newCategory = request.newCategoryName, !newCategory.isEmpty {
            body.appendFormField(named: "newCategoryName", value: newCategory, boundary: boundary)
        }
        body.appendFormField(named: "productDescription", value: request.productDescription, boundary: boundary)
        body.appendFormField(named: "price", value: String(request.price), boundary: boundary)
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.appendFileField(
                named: "imageFile",
                fileName: "product.jpg",
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
        let response = try await APIClient.shared.request(endpoint: endpoint, responseType: CreateProductResponse.self)
        
        print("Product created successfully:", response)
        return response
    }

    func deleteProduct(productID: Int) async throws -> DeleteProductResponse {
        let path = pathBuilder.buildPath("/product/\(productID)")
        let endpoint = APIEndpoint(path: path, method: .delete, requiresAuth: true)
        return try await APIClient.shared.request(endpoint: endpoint, responseType: DeleteProductResponse.self)
    }

    func getProductCategories() async throws -> GetProductCategories {
        let path = pathBuilder.buildPath("/product/categories/all")
        let endpoint = APIEndpoint(path: path, method: .get, requiresAuth: true)
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetProductCategories.self)
    }
}
