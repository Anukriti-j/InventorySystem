import SwiftUI

struct FactoryInjectedView<Content: View>: View {
    @Environment(FactorySessionManager.self) private var factorySessionManager
    let content: (Int) -> Content
    
    var body: some View {
        if let factoryId = factorySessionManager.selectedFactoryID {
            content(factoryId)
        } else {
            SelectFactoryView()
        }
    }
}
