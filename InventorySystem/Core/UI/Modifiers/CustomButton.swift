import SwiftUI

struct CustomButtonModifier: ViewModifier {
    var isDisabled: Bool = false
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(isDisabled ? Color.gray.opacity(0.5) : Color.primaryDark)
            .cornerRadius(8)
            .shadow(color: isDisabled ? Color.clear : Color.primaryLight.opacity(0.5), radius: 4)
            .padding()
            .foregroundColor(.white)
    }
}

extension View {
    func customStyle(isDisabled: Bool = false) -> some View {
        modifier(CustomButtonModifier(isDisabled: isDisabled))
    }
}
