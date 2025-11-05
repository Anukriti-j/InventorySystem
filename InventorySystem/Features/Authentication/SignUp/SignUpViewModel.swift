import Foundation

@Observable
class SignUpViewModel {
    
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var shouldFocusField: Field?
    var nameError: String? = nil
    var emailError: String? = nil
    var passwordError: String? = nil
    
    func handleSignUp() {
        nameError = nil
        emailError = nil
        passwordError = nil
        
        if name.isEmpty {
            shouldFocusField = .name
            nameError = ErrorMessages.requiredField.errorDescription
            return
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
        
        print("SignUp success")
    }

}

