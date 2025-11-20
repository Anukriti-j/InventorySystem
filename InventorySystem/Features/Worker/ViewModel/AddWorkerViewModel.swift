import Foundation
import SwiftUI

@MainActor
@Observable
final class AddWorkerViewModel {
    
    var factoryID: Int = 0
    var name: String = ""
    var email: String = ""
    var bayID: Int = 0
    var selectedImage: UIImage?
    var bays: [Bay] = []
    
    var isLoadingWorker = false
    var showAlert = false
    var alertMessage: String?
    var success = false
    
    init(factoryId: Int?) {
        self.factoryID = factoryId ?? 0
    }
    
    var nameError: String? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Name is required" }
        if trimmed.count < 3 { return "Name must be at least 3 characters" }
        return nil
    }
    
    var emailError: String? {
        let trimmed = email.trimmingCharacters(in: .whitespaces).lowercased()
        if trimmed.isEmpty { return "Email is required" }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: trimmed) ? nil : "Enter a valid email address"
    }
    
    var factoryError: String? {
        factoryID == 0 ? "Please select a factory" : nil
    }
    
    var bayError: String? {
        bayID == 0 ? "Please select a bay" : nil
    }
    
    var isFormValid: Bool {
        nameError == nil &&
        emailError == nil &&
        factoryError == nil &&
        bayError == nil &&
        !isLoadingWorker
    }
    
    func addWorker() async {
        guard isFormValid else { return }
        
        isLoadingWorker = true
        defer { isLoadingWorker = false }
        
        let request = CreateWorkerRequest(
            factoryID: factoryID,
            name: name.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces).lowercased(),
            bayID: bayID,
            image: ""
        )
        
        do {
            let response = try await WorkerService.shared.createWorker(request: request, image: selectedImage)
            success = response.success
            showAlert(with: response.success ? "Worker added successfully!" : response.message)
            if success { resetForm() }
        } catch {
            showAlert(with: "Failed to add worker: \(error.localizedDescription)")
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
            showAlert(with: "Failed to load bays")
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func resetForm() {
        name = ""
        email = ""
        bayID = 0
        selectedImage = nil
    }
}
