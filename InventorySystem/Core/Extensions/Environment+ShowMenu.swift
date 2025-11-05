import Foundation
import SwiftUI

private struct ShowMenuKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var showMenuBinding: Binding<Bool> {
        get { self[ShowMenuKey.self] }
        set { self[ShowMenuKey.self] = newValue }
    }
}
