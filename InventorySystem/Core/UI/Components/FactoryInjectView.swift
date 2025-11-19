import SwiftUI

struct FactoryInjectedView<Content: View>: View {
    @Environment(FactorySessionManager.self) private var factorySessionManager
    let content: (Int) -> Content
    
    var body: some View {
        if let factoryId = factorySessionManager.selectedFactoryID {
            content(factoryId)
        } else {
            // Fallback: either a loading screen or redirect to factory selector
            SelectFactoryView()  // or ProgressView() + redirect logic
        }
    }
}
