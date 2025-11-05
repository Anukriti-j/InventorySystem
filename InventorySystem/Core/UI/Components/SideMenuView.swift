import SwiftUI

struct SideMenuView: View {
    @Environment(NavigationManager.self) private var manager: NavigationManager
    let items: [MenuItem]
    @Environment(\.showMenuBinding) var showMenu
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Inventory System")
                        .font(.title.bold())
                    Text(manager.userRole?.rawValue.capitalized ?? "Unknown")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                Divider().padding(.vertical)
                
                ForEach(items) { item in
                    Button {
                        if let view = item.destination {
                            manager.selectedScreen = view
                            withAnimation { showMenu.wrappedValue = false }
                        }
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: item.icon)
                                .frame(width: 22)
                            Text(item.title)
                        }
                        .font(.headline)
                        .padding(.vertical, 8)
                    }
                }
                
                Spacer()
                
                Button {
                    manager.logout()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Logout")
                    }
                    .font(.headline)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .ignoresSafeArea(.all)
        }
    }
}


#Preview {
    SideMenuView(items: [
        MenuItem(icon: "person.fill", title: "Person", destination: AnyView(Text("Preview Screen")))
    ])
    .environment(NavigationManager())
    .environment(\.showMenuBinding, .constant(false))
}

