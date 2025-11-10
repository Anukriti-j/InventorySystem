import Foundation

@Observable
final class FactorySessionManager {
    static let shared = FactorySessionManager()
    
    private init() {}
    
    var factories: [LoadPHFactoryResponseData] = []
    var selectedFactoryID: Int?
    var isLoading = false
    var alertMessage: String?
    var showAlert = false

    func loadPHFactories(plantHeadID: Int) async {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let response = try await PlantHeadRootService.shared.loadPHFactories(request: LoadPHFactoryRequest(plantHeadID: plantHeadID))
            if response.success {
                factories = response.data
            } else {
                factories = []
            }
        } catch {
            alertMessage = "Cannot fetch factories"
            showAlert = true
            factories = []
        }
    }
}
