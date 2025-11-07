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


// make init private for all singeton services
// PHPersonnelView - check if add supervisor button is appearing only when no supervisor is get and gettin supervisor correctly
