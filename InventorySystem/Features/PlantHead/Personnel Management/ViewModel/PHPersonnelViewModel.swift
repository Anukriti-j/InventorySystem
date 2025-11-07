import Foundation

@Observable
final class PHPersonnelViewModel {
    var showAddSupervisorSheet = false
    var supervisorResponse: GetSupervisor? = nil
    var supervisor: GetSupervisorData? = nil
    let factorySessionManager = FactorySessionManager.shared
    var isLoading = false
    
    var showAlert: Bool = false
    var alertMessage: String = ""
    
    
    let workers = ["Worker 1", "Worker 2", "Worker 3", "Worker 4", "Worker 5"]
    
    func getSupervisor() async {
        isLoading = true
        defer { isLoading = false }
            
        if let factoryID = factorySessionManager.selectedFactoryID {
            do {
                supervisorResponse = try await PHPersonnelService.shared.getSupervisor(factoryID: factoryID)
                supervisor = supervisorResponse?.data
            } catch {
                alertMessage = "\(error)"
                showAlert = true
            }
        } 
    }
}
