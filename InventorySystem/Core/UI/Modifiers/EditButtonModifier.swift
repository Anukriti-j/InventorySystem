import Foundation
import SwiftUI

struct EditButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.blue)
            .frame(width: 36, height: 36)
            .background(Color.blue.opacity(0.1))
            .clipShape(Circle())
    }
    
}

extension View {
    func customEditButtonStyle() -> some View {
        modifier(EditButtonModifier())
    }
}

