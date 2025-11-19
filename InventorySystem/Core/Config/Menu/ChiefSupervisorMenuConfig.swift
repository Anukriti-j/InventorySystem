import SwiftUI

struct ChiefSupervisorMenuConfig {
    static let items: [MenuItem] = [
        MenuItem(icon: "square.grid.2x2", title: "Dashboard") {
            FactoryInjectedView { factoryId in
                DashboardView(userRole: .chiefSupervisor)
            }
        },
        MenuItem(icon: "wrench.and.screwdriver", title: "Tools") {
            FactoryInjectedView { factoryId in
                ToolsListView(factoryId: factoryId, userRole: .chiefSupervisor)
            }
        },
        MenuItem(icon: "building.columns", title: "Central Office Orders") {
            FactoryInjectedView { factoryId in
                EmptyView() // handle this
            }
        },
        MenuItem(icon: "person.fill", title: "Personnel Management") {
            FactoryInjectedView { factoryId in
                WorkerListView(userRole: .chiefSupervisor)
            }
        },
        MenuItem(icon: "wrench.and.screwdriver", title: "Tools Request") {
            FactoryInjectedView { factoryId in
                EmptyView() // Handle this
            }
        }
    ]
}
