import Foundation
import SwiftUI

struct OwnerMenuConfig {
    static var items: [MenuItem] =
    [
        MenuItem(icon: "square.grid.2x2", title: "Dashboard", destination: AnyView(OwnerDashboardView())),
        MenuItem(icon: "building.2.crop.circle", title: "Factories", destination: AnyView(OwnerFactoryView())),
        MenuItem(icon: "cube.box", title: "Products", destination: AnyView(OwnerProductsView())),
        MenuItem(icon: "wrench.and.screwdriver", title: "Tools", destination: AnyView(OwnerToolsListView())),
        MenuItem(icon: "building.columns", title: "Central Office", destination: AnyView(OwnerCOView())),
        MenuItem(icon: "shippingbox.circle", title: "Distributor", destination: AnyView(OwnerDistributorView())),
        MenuItem(icon: "person.crop.circle", title: "Customer", destination: AnyView(OwnerCustomerView())),
        MenuItem(icon: "person.2.badge.gearshape", title: "Worker", destination: AnyView(OwnerWorkerView())),
        MenuItem(icon: "person.fill", title: "PlantHeads", destination: AnyView(OwnerPlantHeadView())),
        MenuItem(icon: "tag", title: "Merchandise", destination: AnyView(OwnerMerchandiseView()))
    ]
}
