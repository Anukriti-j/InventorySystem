import SwiftUI

struct LoadingOrErrorView: View {
    @Environment(SessionManager.self) var manager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Failed to fetch assigned factory.")
                .foregroundColor(.red)
                .padding()
            
            Button("Logout") {
                manager.clearUserSession()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
