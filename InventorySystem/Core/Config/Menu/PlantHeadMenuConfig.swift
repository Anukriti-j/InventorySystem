import Foundation
import SwiftUI

struct PlantHeadMenuConfig {
    static let items: [MenuItem] = [
        MenuItem(icon: "square.grid.2x2", title: "Dashboard", destination: AnyView(PHDashboardView())),
        MenuItem(icon: "cube.box", title: "Products", destination: AnyView(PHProductView())),
        MenuItem(icon: "wrench.and.screwdriver", title: "Tools", destination: AnyView(PHToolView())),
        MenuItem(icon: "building.columns", title: "Central Office Orders", destination: AnyView(PHCOOrderView())),
        MenuItem(icon: "person.fill", title: "Personnel Management", destination: AnyView(PHPersonnelView())),
        MenuItem(icon: "wrench.and.screwdriver", title: "Tools Request", destination: AnyView(PHToolRequestView()))
    ]
}
