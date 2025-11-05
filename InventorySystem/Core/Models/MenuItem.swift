import Foundation
import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let destination: AnyView?
}
