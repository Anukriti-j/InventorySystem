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
    
    func clearUserSession() {
        self.isLoggedIn = false
        self.selectedScreen = nil
        selectedMenuID = nil
                user = nil
                print("User session cleared")
    }
}

//extension SessionManager {
//    var currentScreenTitle: String {
//        switch selectedScreen {
//        case is OwnerFactoryView:      return "Factories"
//        case is OwnerWorkerView:       return "Workers"
//        case is OwnerCOView:           return "Central Officers"
//        case is ReportsView:           return "Reports"
//        default:                       return "Dashboard"
//        }
//    }
//
//    var currentTrailingAction: (() -> Void)? {
//        switch selectedScreen {
//        case is OwnerFactoryView: return { showAddFactorySheet = true }
//        case is OwnerWorkerView:  return { showAddWorkerSheet = true }
//        default:                  return nil
//        }
//    }
//}
