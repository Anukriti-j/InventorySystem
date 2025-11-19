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
            
            Color.white.ignoresSafeArea()
            
            NavigationStack {
                Group {
                    if let selected = manager.selectedScreen {
                        selected
                    } else {
                        content
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.20)) {
                                showMenu.toggle()
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                        }
                    }
                }
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color.white, for: .navigationBar)
            }
            .offset(x: showMenu ? menuWidth : 0)
            .animation(.easeInOut(duration: 0.20), value: showMenu)
            .gesture(
                DragGesture().onEnded { value in
                    withAnimation(.easeInOut(duration: 0.20)) {
                        if value.translation.width < -70 {
                            showMenu = false
                        } else if value.translation.width > 70 && !showMenu {
                            showMenu = true
                        }
                    }
                }
            )
            
            // DIMMED OVERLAY
            if showMenu {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.20)) {
                            showMenu = false
                        }
                    }
                    .offset(x: menuWidth)
            }
            
            // SIDE MENU
            SideMenuView(items: menuItems)
                .frame(width: menuWidth)
                .offset(x: showMenu ? 0 : -menuWidth)
                .animation(.easeInOut(duration: 0.20), value: showMenu)
        }
        .environment(\.showMenuBinding, $showMenu)
    }
}
