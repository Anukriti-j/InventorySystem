import SwiftUI

struct OwnerDashboardView: View {
    @Environment(\.showMenuBinding) var showMenu
    
    var body: some View {
        Text("Owner dashboard view")
            .font(.title)
            .padding(.horizontal)
        
    }
}

#Preview {
    OwnerDashboardView()
        .environment(\.showMenuBinding, .constant(false)) 
}
