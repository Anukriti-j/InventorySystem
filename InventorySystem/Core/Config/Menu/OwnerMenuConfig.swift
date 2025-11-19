import Foundation
import SwiftUI

struct OwnerMenuConfig {
    static var items: [MenuItem] =
    [
        MenuItem(icon: "square.grid.2x2", title: "Dashboard", destination: AnyView(DashboardView(userRole: .owner))),
        MenuItem(icon: "building.2.crop.circle", title: "Factories", destination: AnyView(FactoryView())),
        MenuItem(icon: "cube.box", title: "Products", destination: AnyView(ProductsListView(userRole: .owner))),
        MenuItem(icon: "wrench.and.screwdriver", title: "Tools", destination: AnyView(ToolsListView(userRole: .owner))),
        MenuItem(icon: "building.columns", title: "Central Office", destination: AnyView(CentralOfficerListView())),
        MenuItem(icon: "shippingbox.circle", title: "Distributor", destination: AnyView(DistributorListView())),
        MenuItem(icon: "person.crop.circle", title: "Customer", destination: AnyView(CustomerListView())),
        MenuItem(icon: "person.2.badge.gearshape", title: "Worker", destination: AnyView(WorkerListView(userRole: .owner))),
        MenuItem(icon: "person.fill", title: "PlantHeads", destination: AnyView(PlantHeadListView())),
        MenuItem(icon: "tag", title: "Merchandise", destination: AnyView(MerchandiseListView(userRole: .owner)))
    ]
}
