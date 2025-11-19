import SwiftUI

@Observable
final class ChiefSupervisorViewModel {
    
    var supervisors: [GetSupervisorData]? = nil
    var selectedFactoryId: Int?
    
    var isLoadingSupervisor = false
    
    var showAddSupervisorSheet = false
    
    var showAlert = false
    var alertMessage = ""
    
    init(selectedFactoryId: Int? = nil) {
        self.selectedFactoryId = selectedFactoryId
    }
    
    func getSupervisor() async {
        print("selectedfactoryid: \(selectedFactoryId)")
        print("func get supervisor called")
        isLoadingSupervisor = true
        defer { isLoadingSupervisor = false }
        
        do {
            guard let factoryId = selectedFactoryId else {
                return
            }
            let response = try await ChiefSupervisorService.shared.getSupervisor(factoryID: factoryId)
            supervisors = response.data
        } catch {
            showAlert(with: "Failed to load supervisors: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
