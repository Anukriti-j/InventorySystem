import SwiftUI

@main
struct InventorySystemApp: App {
    @State var manager = SessionManager()
    @State var factorySessionManager = FactorySessionManager()
    
    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environment(manager)
                .environment(factorySessionManager)
                .onChange(of: manager.isLoggedIn) { _, isLoggedIn in
                    if !isLoggedIn {
                        factorySessionManager.resetForLogout()
                    }
                }
        }
    }
}

// define protocols for services
// failed to create central officer

// remove factory filters from tools
// edit factory
// on any operation add, update, delete - fetch call


// add an alert message while adding planhead- if no unassigned factpries available cannot add planthead

// multiple factories filter not working in all workers for owner end
// sare create me validations
