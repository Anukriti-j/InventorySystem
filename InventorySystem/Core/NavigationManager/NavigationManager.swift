import Foundation
import SwiftUI

@Observable
final class NavigationManager {
    var isLoggedIn: Bool = true
    var userRole: UserRole? = .plantHead
    var selectedScreen: AnyView? = nil
    
    func login(as role: UserRole) {
            self.userRole = role
            self.isLoggedIn = true
            self.selectedScreen = nil
        }
        
        // MARK: - LOGOUT
        func logout() {
            self.isLoggedIn = false
            self.selectedScreen = nil
        }
}


