import SwiftUI

struct AppEntryView: View {
    @Environment(SessionManager.self) var manager
    @Environment(FactorySessionManager.self) var factorySessionManager
    
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
                DashboardView(userRole: .owner)
            }
        case .plantHead:
            if let factoryId = factorySessionManager.selectedFactoryID {
                DashboardContainer(menuItems: PlantHeadMenuConfig.items) {
                    DashboardView(userRole: .plantHead)
                }
            } else {
                SelectFactoryView()
            }
            
        case .chiefSupervisor:
            if let factoryId = factorySessionManager.selectedFactoryID {
                DashboardContainer(menuItems: ChiefSupervisorMenuConfig.items) {
                    DashboardView(userRole: .chiefSupervisor)
                }
            } else {
                LoadingOrErrorView()
            }
        case .worker:
            DashboardContainer(menuItems: PlantHeadMenuConfig.items) {
                DashboardView(userRole: .worker)
            }
        case .distributor:
            DashboardContainer(menuItems: PlantHeadMenuConfig.items) {
                DashboardView(userRole: .distributor)
            }
        case .centralOfficer:
            DashboardContainer(menuItems: PlantHeadMenuConfig.items) {
                DashboardView(userRole: .centralOfficer)
            }
        case .customer:
            DashboardContainer(menuItems: PlantHeadMenuConfig.items) {
                DashboardView(userRole: .customer)
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
