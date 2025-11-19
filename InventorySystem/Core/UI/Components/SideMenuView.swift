import SwiftUI

struct SideMenuView: View {
    @Environment(SessionManager.self) private var manager: SessionManager
    @Environment(\.showMenuBinding) var showMenu
    
    let items: [MenuItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(manager.user?.userName ?? "Guest User")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text(manager.user?.email ?? "No email")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let role = manager.user?.userRole {
                        Text(role.rawValue.capitalized)
                            .font(.caption.weight(.medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.top, 60)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(items) { item in
                        let isSelected = manager.selectedMenuID == item.id
                        
                        Button {
                            let destinationView = item.destination()
                            
                            manager.selectedScreen = AnyView(destinationView)
                            manager.selectedMenuID = item.id
                            
                            withAnimation(.easeInOut(duration: 0.20)) {
                                showMenu.wrappedValue = false
                            }
                        } label: {
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(isSelected ? Color.blue : Color.clear)
                                    .frame(width: 4)
                                
                                HStack(spacing: 14) {
                                    Image(systemName: item.icon)
                                        .font(.title3)
                                        .frame(width: 24)
                                    
                                    Text(item.title)
                                        .font(.body)
                                    
                                    Spacer()
                                }
                                .foregroundColor(isSelected ? .blue : .primary)
                                .padding(.vertical, 16)
                                .padding(.leading, 20)
                                .padding(.trailing, 24)
                                .background(isSelected ? Color.blue.opacity(0.08) : Color.clear)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Spacer()
            
            Divider()
                .padding(.horizontal, 24)
            
            Button {
                manager.clearUserSession()
                withAnimation(.easeInOut(duration: 0.20)) {
                    showMenu.wrappedValue = false
                }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.title3)
                        .frame(width: 24)
                    
                    Text("Logout")
                        .font(.body.weight(.medium))
                    
                    Spacer()
                }
                .foregroundColor(.red)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 2, y: 0)
        .ignoresSafeArea()
    }
}
