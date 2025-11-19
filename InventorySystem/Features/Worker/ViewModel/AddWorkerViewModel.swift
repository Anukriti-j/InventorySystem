import SwiftUI

@MainActor
@Observable
final class AddWorkerViewModel {
    
    var factoryID: Int = 0 { didSet { validateFactory() } }
    var name: String = "" { didSet { validateName() } }
    var email: String = "" { didSet { validateEmail() } }
    var bayID: Int = 0 { didSet { validateBay() } }
    
    var bays: [Bay] = []
    var selectedImage: UIImage?
    
    var nameError: String?
    var emailError: String?
    var factoryError: String?
    var bayError: String?
    
    var isLoadingWorker = false
    var showAlert = false
    var alertMessage = ""
    var success = false
    
    init(factoryId: Int?) {
        self.factoryID = factoryId ?? 0
        validateFactory()
    }
    
    var isFormValid: Bool {
        nameError == nil &&
        emailError == nil &&
        factoryError == nil &&
        bayError == nil
    }
    
    func validateName() {
        nameError = name.trimmingCharacters(in: .whitespaces).isEmpty
        ? "Name is required"
        : nil
    }
    
    func validateEmail() {
        if email.isEmpty {
            emailError = "Email is required"
        } else if !email.contains("@") || !email.contains(".") {
            emailError = "Enter a valid email"
        } else {
            emailError = nil
        }
    }
    
    func validateFactory() {
        factoryError = factoryID == 0 ? "Please select a factory" : nil
    }
    
    func validateBay() {
        bayError = bayID == 0 ? "Please select a bay" : nil
    }
    
    func addWorker() async {
        guard isFormValid else { return }
        
        isLoadingWorker = true
        defer { isLoadingWorker = false }
        
        let request = CreateWorkerRequest(
            factoryID: factoryID,
            name: name,
            email: email,
            bayID: bayID,
            image: ""
        )
        
        do {
            let response = try await WorkerService.shared.createWorker(request: request, image: selectedImage)
            success = response.success
            showAlert(with: response.message)
        } catch {
            showAlert(with: "Cannot add worker: \(error.localizedDescription)")
        }
    }
    
    func getWorkersBay() async {
        guard factoryID != 0 else {
            bays = []
            return
        }
        
        do {
            let response = try await WorkerService.shared.getWorkersBay(factoryId: factoryID)
            bays = response.data ?? []
        } catch {
            bays = []
            showAlert(with: "Cannot fetch bays: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
