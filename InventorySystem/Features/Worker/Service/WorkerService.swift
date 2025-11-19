import Foundation
import SwiftUI

final class WorkerService {
    static let shared = WorkerService()
    let pathBuilder = APIPathBuilder()
    
    func createWorker(request: CreateWorkerRequest, image: UIImage?) async throws -> CreateWorkerResponse {
        let path = pathBuilder.buildPath("/owner/create/worker")
        let boundary = UUID().uuidString
        var body = Data()
        
        body.appendFormField(named: "name", value: request.name, boundary: boundary)
        body.appendFormField(named: "email", value: request.email, boundary: boundary)
        body.appendFormField(named: "bayId", value: String(request.bayID), boundary: boundary)
        body.appendFormField(named: "factoryId", value: String(request.factoryID), boundary: boundary)
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.appendFileField(
                named: "imageFile",
                fileName: "worker.jpg",
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
        
        let response = try await APIClient.shared.request(endpoint: endpoint, responseType: CreateWorkerResponse.self)
        return response
    }
    
    func fetchWorkers(
        page: Int,
        size: Int,
        sortBy: String?,
        sortDirection: String?,
        status: String?,
        factoryId: Int?,
        search: String?
    ) async throws -> GetAllWorkers {
        print("fetching workers")
        let path = pathBuilder.buildPath(
            "/owner/worker/getall",
            queryItems: [
                "page": "\(page)",
                "size": "\(size)",
                "sortBy": sortBy,
                "sortDirection": sortDirection,
                "status": status,
                "search": search,
                "factoryId": factoryId.map { "\($0)" }
            ]
        )
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetAllWorkers.self)
    }
    
    func getWorkersBay(factoryId: Int) async throws -> GetWorkersBay {
        let path = pathBuilder.buildPath("/owner/\(factoryId)/available-bays")
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: GetWorkersBay.self)
    }
    
    func deleteWorker(workerID: Int) async throws -> DeleteWorkerResponse {
        let path = pathBuilder.buildPath("/owner/worker/delete/\(workerID)")
        let endpoint = APIEndpoint(
            path: path,
            method: .delete,
            requiresAuth: true
        )
        return try await APIClient.shared.request(endpoint: endpoint, responseType: DeleteWorkerResponse.self)
    }
}
