import SwiftUI

struct SideMenuView: View {
    @Environment(SessionManager.self) private var manager: SessionManager
    let items: [MenuItem]
    @Environment(\.showMenuBinding) var showMenu
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(manager.name ?? "Unknown")
                        .font(.title.bold())
                    Text(manager.email ?? "Not found")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                    Text(manager.userRole?.rawValue.capitalized ?? "Unknown")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                Divider().padding(.vertical)
                
                ForEach(items) { item in
                    let isSelected = manager.selectedMenuID == item.id
                    
                    Button {
                        if let view = item.destination {
                            manager.selectedScreen = view
                            manager.selectedMenuID = item.id
                            withAnimation { showMenu.wrappedValue = false }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            // ✅ Left indicator
                            Rectangle()
                                .fill(isSelected ? Color.blue : .clear)
                                .frame(width: 4)
                            
                            HStack(spacing: 14) {
                                Image(systemName: item.icon)
                                Text(item.title)
                            }
                            .foregroundColor(isSelected ? .blue : .primary)
                            .padding(.vertical, 12)
                            .padding(.leading, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(isSelected ? Color.blue.opacity(0.08) : .clear)                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Button {
                    manager.clearUserSession()
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
    .environment(SessionManager())
    .environment(\.showMenuBinding, .constant(false))
}

