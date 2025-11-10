import Foundation
import SwiftUI

@Observable
final class SessionManager {
    var isLoggedIn: Bool = false
    var user: LoggedInUser?
    var selectedScreen: AnyView? = nil
    var selectedMenuID: UUID? = nil
    
    func setUpUserSession(user: LoggedInUser) {
        self.isLoggedIn = true
        self.user = LoggedInUser(
            id: user.id,
            userName: user.userName,
            email: user.email,
            userRole: user.userRole
        )
        
    }
    
    // MARK: - LOGOUT
    func clearUserSession() {
        self.isLoggedIn = false
        self.selectedScreen = nil
    }
}


