import SwiftUI

@main
struct InventorySystemApp: App {
    @State var manager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environment(manager)
        }
    }
}
