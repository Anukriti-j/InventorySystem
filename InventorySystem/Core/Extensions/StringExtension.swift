import Foundation

extension String {
    
    var isEmail: Bool {
        FormValidator.isValidEmail(self)
    }
    
    var isPassword: Bool {
        FormValidator.isValidPassword(self)
    }
    
    var isPhone: Bool {
        FormValidator.isValidPhone(self)
    }
}
