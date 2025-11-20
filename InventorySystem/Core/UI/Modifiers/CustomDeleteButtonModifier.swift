import Foundation
import SwiftUI

struct CustomDeleteButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.red)
            .frame(width: 36, height: 36)
            .background(Color.red.opacity(0.1))
            .clipShape(Circle())
    }
    
}

extension View {
    func customDeleteButtonStyle() -> some View {
        modifier(CustomDeleteButtonModifier())
    }
}

