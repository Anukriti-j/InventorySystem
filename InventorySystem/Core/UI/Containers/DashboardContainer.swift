import SwiftUI

struct DashboardContainer<Content: View>: View {
    @Environment(SessionManager.self) private var manager: SessionManager
    @State private var showMenu = false
    
    let menuItems: [MenuItem]
    let content: Content
    
    private let menuWidth: CGFloat = 300
    
    init(menuItems: [MenuItem], @ViewBuilder content: () -> Content) {
        self.menuItems = menuItems
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                
                Group {
                    if let selected = manager.selectedScreen {
                        selected
                    } else {
                        content
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .offset(x: showMenu ? menuWidth : 0)
            .animation(.easeInOut(duration: 0.05), value: showMenu)
            
            if showMenu {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.05)) {
                            showMenu = false
                        }
                    }
                    .offset(x: menuWidth) // Overlay starts after menu
            }
            
            SideMenuView(items: menuItems)
                .frame(width: menuWidth)
                .offset(x: showMenu ? 0 : -menuWidth)
                .animation(.easeInOut(duration: 0.05), value: showMenu)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        if value.translation.width < -50 {
                            showMenu = false
                        } else if value.translation.width > 50 && !showMenu {
                            showMenu = true
                        }
                    }
                }
        )
        .environment(\.showMenuBinding, $showMenu)
    }
}
