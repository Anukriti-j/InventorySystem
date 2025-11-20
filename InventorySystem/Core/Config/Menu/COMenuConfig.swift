import SwiftUI

struct CentralOfficerMenuConfig {
    static let items: [MenuItem] = [
        MenuItem(icon: "square.grid.2x2", title: "Dashboard") {
            FactoryInjectedView { factoryId in
                DashboardView(userRole: .centralOfficer) // Handle this
            }
        },
        MenuItem(
            icon: "cube.box", title: "Products",
            destination: AnyView(ProductsListView(userRole: .centralOfficer))
        ),
        MenuItem(icon: "building.columns", title: "Requests") {
            FactoryInjectedView { factoryId in
                ProductRestockOrderView()
            }
        },
        MenuItem(icon: "person.fill", title: "Rewards") {
            FactoryInjectedView { factoryId in
                MerchandiseListView(userRole: .centralOfficer)
            }
        },
        MenuItem(icon: "wrench.and.screwdriver", title: "Distributors/Customers") {
            FactoryInjectedView { factoryId in
                DistributorListView()
            }
        }
    ]
}
