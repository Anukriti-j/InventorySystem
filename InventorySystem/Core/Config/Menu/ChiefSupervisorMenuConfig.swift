import SwiftUI

struct ChiefSupervisorMenuConfig {
    static let items: [MenuItem] = [
        MenuItem(icon: "square.grid.2x2", title: "Dashboard") {
            FactoryInjectedView { factoryId in
                DashboardView(userRole: .chiefSupervisor)
            }
        },
        MenuItem(icon: "wrench.and.screwdriver", title: "Tools Inventory") {
            FactoryInjectedView { factoryId in
                ToolsListView(factoryId: factoryId, userRole: .chiefSupervisor)
            }
        },
        MenuItem(icon: "building.columns", title: "Tools Request") {
            FactoryInjectedView { factoryId in
                ToolRequestView()
            }
        },
        MenuItem(icon: "person.fill", title: "Workers") {
            FactoryInjectedView { factoryId in
                WorkerListView(userRole: .chiefSupervisor)
            }
        },
        MenuItem(icon: "wrench.and.screwdriver", title: "Tools Return") {
            FactoryInjectedView { factoryId in
                ToolReturnView()
            }
        }
    ]
}
