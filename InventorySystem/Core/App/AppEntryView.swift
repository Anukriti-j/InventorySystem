import SwiftUI

struct AppEntryView: View {
    @Environment(SessionManager.self) var manager
    
    var body: some View {
            Group {
                if !manager.isLoggedIn {
                    LoginView()
                } else {
                    dashboardViewForRole()
                }
            }
    }
}

extension AppEntryView {
    @ViewBuilder
    private func dashboardViewForRole() -> some View {
        switch manager.user?.userRole {
        case .owner:
            DashboardContainer(menuItems: OwnerMenuConfig.items) {
                OwnerDashboardView()
            }
        case .plantHead:
            DashboardContainer(menuItems: PlantHeadMenuConfig.items) {
                PlantHeadRootContainer()
            }
            
            // TODO: setup menu config for these roles
        case .chiefSupervisor:
            DashboardContainer(menuItems: PlantHeadMenuConfig.items) {
                PHDashboardView()
            }
        case .worker:
            DashboardContainer(menuItems: PlantHeadMenuConfig.items) {
                PHDashboardView()
            }
        case .distributor:
            DashboardContainer(menuItems: PlantHeadMenuConfig.items) {
                PHDashboardView()
            }
        case .centralOfficer:
            DashboardContainer(menuItems: PlantHeadMenuConfig.items) {
                PHDashboardView()
            }
        case .customer:
            DashboardContainer(menuItems: PlantHeadMenuConfig.items) {
                PHDashboardView()
            }
        case .unknown:
            LoginView()
        case .none:
            LoginView()
        }
    }
}

#Preview {
    AppEntryView()
}
