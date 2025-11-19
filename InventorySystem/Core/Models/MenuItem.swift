import Foundation
import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    @ViewBuilder let destination: () -> any View
    
    init(icon: String, title: String, @ViewBuilder destination: @escaping () -> any View) {
        self.icon = icon
        self.title = title
        self.destination = destination
    }
    
    init(icon: String, title: String, destination view: any View) {
        self.icon = icon
        self.title = title
        self.destination = { AnyView(view) }
    }
}
