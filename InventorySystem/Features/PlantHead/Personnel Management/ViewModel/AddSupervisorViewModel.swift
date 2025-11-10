import Foundation

@Observable
final class AddSupervisorViewModel {
    var name: String = "" {
        didSet {
            validateName()
        }
    }
    var email: String = "" {
        didSet {
           validateEmail()
        }
    }
    
    var nameError: String?
    var emailError: String?
    var success = false
    
    var showAlert = false
    var alertMessage: String?
    var createChiefResponse: CreateChiefResponse?
    
    var isFormValid: Bool {
        if validateName() && validateEmail() {
            return true
        } else {
            return false
        }
    }
    
    func validateName() -> Bool {
        if name.isEmpty {
            nameError = ErrorMessages.requiredField.errorDescription
            return false
        } else {
            nameError = nil
            return true
        }
    }
    
    func validateEmail() -> Bool {
        if email.isEmpty {
            emailError = ErrorMessages.requiredField.errorDescription
            return false
        } else if !email.isEmail {
            emailError = ErrorMessages.invalidEmail.errorDescription
            return false
        } else {
            emailError = nil
            return true
        }
    }
    
    func addChiefSupervisor(factoryID: Int) async {

        let request = CreateChiefRequest(name: name, email: email, factoryID: factoryID)
        do {
            createChiefResponse = try await PHPersonnelService.shared.addChiefSupervisor(request: request)
            if createChiefResponse?.success == true {
                success = true
            }
            if let message = createChiefResponse?.message {
                showAlert(with: message)
            }
        } catch {
            showAlert(with: "Cannot create chief supervisor: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
