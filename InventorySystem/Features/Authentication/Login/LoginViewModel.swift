import Foundation

enum Field {
    case name, email, password
}

@Observable
class LoginViewModel {
    var response: [LoginResponse]?
    var email: String = ""
    var password: String = ""
    var shouldFocusField: Field?
    var emailError: String? = nil
    var passwordError: String? = nil
   
    func handleLogin() async {
        emailError = nil
        passwordError = nil
        
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
            response = try await AuthService.shared.login()
        } catch {
            print(error)
        }
        print("Login success")
    }

}
