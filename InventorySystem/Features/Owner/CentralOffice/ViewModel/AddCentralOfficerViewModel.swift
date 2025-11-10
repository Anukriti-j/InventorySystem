import Foundation

@MainActor
final class AddCentralOfficerViewModel: ObservableObject {
    @Published var name: String = "" {
        didSet {
            _ = validateName()
        }
    }
    @Published var email: String = "" {
        didSet {
            _ = validateEmail()
        }
    }
    @Published var isLoading = false

    @Published var nameError: String?
    @Published var emailError: String?

    @Published var showAlert: Bool = false
    @Published var alertMessage: String?
    @Published var success: Bool = false

    var isFormValid: Bool {
        nameError == nil && emailError == nil && !name.isEmpty && !email.isEmpty
    }

    @MainActor
    func validateName() -> Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = ErrorMessages.requiredField.errorDescription
            return false
        }
        nameError = nil
        return true
    }

    func validateEmail() -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            emailError = ErrorMessages.requiredEmail.errorDescription
            return false
        } else if !trimmed.isEmail {
            emailError = ErrorMessages.invalidEmail.errorDescription
            return false
        }
        emailError = nil
        return true
    }

    @MainActor
    func createCentralOfficer() async {
        guard validateName(), validateEmail() else { return }

        isLoading = true
        defer { isLoading = false }

        let request = CreateCORequest(name: name, email: email)

        do {
            let response = try await OwnerCentralOfficeService.shared.createCentralOfficer(request: request)
            success = response.success
            showAlert(with: response.message)

            if success {
                resetForm()
            }
        } catch let error as APIError {
            showAlert(with: "Failed to create central officer: \(error.localizedDescription)")
        } catch {
            showAlert(with: "Failed to create central officer: \(error.localizedDescription)")
        }
    }

    private func resetForm() {
        name = ""
        email = ""
        nameError = nil
        emailError = nil
    }

    private func showAlert(with message: String?) {
        alertMessage = message
        showAlert = true
    }
}
