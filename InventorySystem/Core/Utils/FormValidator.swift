import Foundation

final class FormValidator {
    
    static func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES[c] %@", regex).evaluate(with: email)
    }
    
    static func isValidPhone(_ phone: String) -> Bool {
        let regex = #"^[0-9]{10}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: phone)
    }

    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
}

