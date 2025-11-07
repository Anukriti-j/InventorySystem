import Foundation

enum Field {
    case name, email, password
}

@Observable
class LoginViewModel {
    var response: LoginResponse?
    var email: String = ""
    var password: String = ""
    var shouldFocusField: Field?
    var emailError: String? = nil
    var passwordError: String? = nil
    var alertMessage: String? = nil
    var showAlert: Bool = false
    var isLoading: Bool = false
    
    func handleLogin(sessionManager: SessionManager) async {
        emailError = nil
        passwordError = nil
        alertMessage = nil
        showAlert = false
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        if email.isEmpty {
            shouldFocusField = .email
            emailError = ErrorMessages.requiredEmail.errorDescription
            return
        }
        
        if password.isEmpty {
            shouldFocusField = .password
            passwordError = ErrorMessages.requiredPassword.errorDescription
            return
        }
        
        if !email.isEmail {
            shouldFocusField = .email
            emailError = ErrorMessages.invalidEmail.errorDescription
            return
        }
        
        if !password.isPassword {
            shouldFocusField = .password
            passwordError = ErrorMessages.invalidPassword.errorDescription
            return
        }
        
        do {
            response = try await AuthService.shared.login(
                request: LoginRequest(email: email, password: password)
            )
            
            if let token = response?.data.token {
                KeychainManager.shared.save(token: token)
            }
            
            if let roleString = response?.data.role,
               let role = UserRole(rawValue: roleString) {
                sessionManager.setUpUserSession(
                    as: role,
                    name: response?.data.username ?? "Unknown",
                    email: response?.data.email ?? "Not found"
                )
            } else {
                alertMessage = ErrorMessages.notRecognized.errorDescription
                showAlert = true
            }
            
        } catch let apiError as APIError {
            alertMessage = apiError.errorDescription
            showAlert = true
            
        } catch {
            alertMessage = ErrorMessages.unknownError.errorDescription
            showAlert = true
        }
    }
    
}
