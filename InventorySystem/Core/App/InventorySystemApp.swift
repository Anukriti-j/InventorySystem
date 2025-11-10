import SwiftUI

@main
struct InventorySystemApp: App {
    @State var manager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environment(manager)
        }
    }
}

// PHPersonnelView - check if add supervisor button is appearing only when no supervisor is get and gettin supervisor correctly
// define protocols for services
// failed to create central officer
