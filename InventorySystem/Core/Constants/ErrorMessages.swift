import Foundation

enum ErrorMessages {
    case requiredField
    case requiredEmail
    case requiredPassword
    case invalidEmail
    case invalidPassword
    
    var errorDescription: String? {
        
        switch self {
        case .requiredField:
            return "This field is required"
        case .requiredEmail:
            return "Email is required"
        case .requiredPassword:
            return "Password is required"
        case .invalidEmail:
            return "Enter a valid email address"
        case .invalidPassword:
            return "Password must be at least 6 characters"
        }
    }
}

