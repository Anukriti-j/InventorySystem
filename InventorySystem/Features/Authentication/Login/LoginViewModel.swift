import Foundation

enum Field {
    case name, email, password
}

@Observable
class LoginViewModel {
    var response: LoginResponse?
    var email: String = "" {
        didSet {
            validateEmail()
        }
    }
    var password: String = "" {
        didSet {
            validatePassword()
        }
    }
    var shouldFocusField: Field?
    var emailError: String? = nil
    var passwordError: String? = nil
    var alertMessage: String? = nil
    var showAlert: Bool = false
    var isLoading: Bool = false
    
    var isFormValid: Bool {
        if validateEmail() && validatePassword() {
            return true
        } else {
            return false
        }
    }
    
    func validateEmail() -> Bool {
        if email.isEmpty {
            shouldFocusField = .email
            emailError = ErrorMessages.requiredEmail.errorDescription
            return false
        }
        else if !email.isEmail {
            shouldFocusField = .email
            emailError = ErrorMessages.invalidEmail.errorDescription
            return false
        }
        emailError = nil
        return true
    }
    
    func validatePassword() -> Bool {
        if password.isEmpty {
            shouldFocusField = .password
            passwordError = ErrorMessages.requiredPassword.errorDescription
            return false
        }
        else if !password.isPassword {
            shouldFocusField = .password
            passwordError = ErrorMessages.invalidPassword.errorDescription
            return false
        }
        passwordError = nil
        return true
    }
    
    // MARK: Alert messages are not showing properly
    func handleLogin(sessionManager: SessionManager) async {
        isLoading = true
        defer {
            isLoading = false
            resetForm() // MARK: check if this is right
        }
        
        do {
            response = try await AuthService.shared.login(
                request: LoginRequest(email: email, password: password)
            )
            
            if let token = response?.data.token {
                KeychainManager.shared.save(token: token)
            }
            
            if let data = response?.data {
                let role = UserRole(rawValue: data.role) ?? .unknown
                sessionManager.setUpUserSession(
                    user: LoggedInUser(
                        id: data.id,
                        userName: data.username,
                        email: data.email,
                        userRole: role
                    )
                )
            } else {
                print(response?.message)
                showAlert(with: ErrorMessages.notRecognized.errorDescription)
            }
        } catch let apiError as APIError {
            showAlert(with: apiError.errorDescription)
            
        } catch {
            showAlert(with: ErrorMessages.unknownError.errorDescription)
        }
    }
    
    private func showAlert(with message: String?) {
        alertMessage = message
        showAlert = true
    }
    
    private func resetForm() {
        emailError = nil
        passwordError = nil
    }
}
