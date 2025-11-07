import Foundation

@Observable
class AddPlantHeadViewModel {
    var name: String = ""
    var email: String = ""
    var success: Bool = false
    var response: CreatePHResponse?
    
    var nameError: String?
    var emailError: String?

    var alertMessage: String?
    var showAlert: Bool = false
    
    var isFormValid: Bool {
        guard !name.isEmpty && !email.isEmpty else {
            nameError = ErrorMessages.requiredField.errorDescription
            return false
        }
        guard email.isEmail else {
            emailError = ErrorMessages.invalidEmail.errorDescription
            return false
        }
        return true
    }
    
    func createPlantHead() async {
        do {
            response = try await OwnerPHService.shared.createPlantHead(
                request: CreatePHRequest(
                    username: name,
                    email: email,
                    factoryID: 1
                )
            )
            alertMessage = response?.message
            success = true
        } catch {
            success = false
            alertMessage = response?.message
        }
    }
}
