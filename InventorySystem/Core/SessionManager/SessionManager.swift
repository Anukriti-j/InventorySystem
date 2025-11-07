import Foundation
import SwiftUI

@Observable
final class SessionManager {
    var isLoggedIn: Bool = true
    var userRole: UserRole? = .plantHead
    var name: String?
    var email: String?
    var selectedScreen: AnyView? = nil
    var selectedMenuID: UUID? = nil
    
    func setUpUserSession(as role: UserRole, name: String, email: String) {
        self.userRole = role
        self.isLoggedIn = true
        self.selectedScreen = nil
        self.name = name
        self.email = email
    }
    
    // MARK: - LOGOUT
    func clearUserSession() {
        self.isLoggedIn = false
        self.selectedScreen = nil
    }
}


