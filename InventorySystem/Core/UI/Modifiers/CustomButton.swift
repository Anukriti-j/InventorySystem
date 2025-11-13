import SwiftUI

struct CustomButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.primaryDark)
            .cornerRadius(8)
            .shadow(color: Color.primaryLight.opacity(0.5) , radius: 4)
            .padding()
    }
}

extension View {
    func customStyle() -> some View {
        modifier(CustomButtonModifier())
    }
}
