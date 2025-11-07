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
