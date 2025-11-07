import Foundation

@Observable
final class FactorySessionManager {
    static let shared = FactorySessionManager()
    
    private init() { Task { await loadPHFactories() } }
    
    var factories: [LoadPHFactoryResponseData] = []
    var selectedFactoryID: Int?

    var alertMessage: String?
    var showAlert = false

    // TODO: Pass plantheadID after login
    func loadPHFactories() async {
        do {
            let response = try await PlantHeadRootService.shared.loadPHFactories(request: LoadPHFactoryRequest(plantHeadID: 12))
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
