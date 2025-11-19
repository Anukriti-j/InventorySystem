import SwiftUI

struct PlantHeadMenuConfig {
    static let items: [MenuItem] = [
        MenuItem(icon: "house.fill", title: "Factory") {
            FactoryInjectedView { factoryId in
                SelectFactoryView()
            }
        },
        MenuItem(icon: "square.grid.2x2", title: "Dashboard") {
            FactoryInjectedView { factoryId in
                DashboardView(userRole: .plantHead)
            }
        },
        MenuItem(icon: "cube.box", title: "Products") {
            FactoryInjectedView { factoryId in
                ProductsListView(userRole: .plantHead)
            }
        },
        MenuItem(icon: "wrench.and.screwdriver", title: "Tools") {
            FactoryInjectedView { factoryId in
                ToolsListView(factoryId: factoryId, userRole: .plantHead)
            }
        },
        MenuItem(icon: "building.columns", title: "Central Office Orders") {
            FactoryInjectedView { factoryId in
                EmptyView() // handle this
            }
        },
        MenuItem(icon: "person.fill", title: "Chief Supervisor") {
            FactoryInjectedView { factoryId in
                ChiefSupervisorView(factoryId: factoryId)  
            }
        },
        MenuItem(icon: "person.fill", title: "Workers") {
            FactoryInjectedView { factoryId in
                WorkerListView(factoryId: factoryId, userRole: .plantHead)
            }
        },
        MenuItem(icon: "wrench.and.screwdriver", title: "Tools Request") {
            FactoryInjectedView { factoryId in
               EmptyView() // handle this
            }
        }
    ]
}
