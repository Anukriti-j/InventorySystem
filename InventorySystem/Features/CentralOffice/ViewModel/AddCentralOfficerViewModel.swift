import Foundation
import SwiftUI

@MainActor
final class AddCentralOfficerViewModel: ObservableObject {

    @Published var name: String = "" {
        didSet {
            validateName()
            validateForm()
        }
    }

    @Published var email: String = "" {
        didSet {
            validateEmail()
            validateForm()
        }
    }

    @Published var nameError: String?
    @Published var emailError: String?

    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?
    @Published var success = false
    @Published var isFormValid: Bool = false

    private func validateForm() {
        isFormValid = validateName() && validateEmail()
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

    func createCentralOfficer() async {
        guard isFormValid else { return }

        isLoading = true
        defer { isLoading = false }

        let request = CreateCORequest(name: name, email: email)

        do {
            let response = try await CentralOfficeService.shared.createCentralOfficer(request: request)
            success = response.success
            showAlert(with: response.message)

            if success { resetForm() }

        } catch let error as APIError {
            showAlert(with: error.localizedDescription)
        } catch {
            showAlert(with: error.localizedDescription)
        }
    }

    private func resetForm() {
        name = ""
        email = ""
        nameError = nil
        emailError = nil
        validateForm()
    }

    private func showAlert(with message: String?) {
        alertMessage = message
        showAlert = true
    }
}
