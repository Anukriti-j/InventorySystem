import Foundation

@MainActor
final class AddSupervisorViewModel: ObservableObject {
    
    @Published var name: String = "" {
        didSet { validateName() }
    }
    
    @Published var email: String = "" {
        didSet { validateEmail() }
    }
    
    @Published var nameError: String?
    @Published var emailError: String?
    
    @Published var success = false
    @Published var showAlert = false
    @Published var alertMessage: String?
    @Published var createChiefResponse: CreateChiefResponse?
    
    var isFormValid: Bool {
        validateName() && validateEmail()
    }
    
    @discardableResult
    func validateName() -> Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = ErrorMessages.requiredField.errorDescription
            return false
        }
        nameError = nil
        return true
    }
    
    @discardableResult
    func validateEmail() -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            emailError = ErrorMessages.requiredEmail.errorDescription
            return false
        }
        if !trimmed.isEmail {
            emailError = ErrorMessages.invalidEmail.errorDescription
            return false
        }
        emailError = nil
        return true
    }
    
    func addChiefSupervisor(factoryID: Int) async {
        let request = CreateChiefRequest(name: name, email: email, factoryID: factoryID)
        do {
            createChiefResponse = try await ChiefSupervisorService.shared.addChiefSupervisor(request: request)
            success = createChiefResponse?.success == true
            showAlert(with: createChiefResponse?.message ?? "")
        } catch {
            showAlert(with: error.localizedDescription)
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
