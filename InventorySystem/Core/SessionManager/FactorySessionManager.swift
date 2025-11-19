import Foundation

@Observable
final class FactorySessionManager {
    var factories: [LoadPHFactoryResponseData] = []
    var selectedFactoryID: Int? {
        didSet {
            print("Selected Factory Changed → \(selectedFactoryID ?? -1)")
        }
    }
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
                if let data = response.data {
                    factories = data
                }
            } else {
                factories = []
            }
        } catch {
            alertMessage = "Cannot fetch factories"
            showAlert = true
            factories = []
        }
    }
    
    func resetForLogout() {
        selectedFactoryID = nil
        factories = []
        isLoading = false
        alertMessage = nil
        showAlert = false
        print("FactorySessionManager fully reset on logout")
    }
}

