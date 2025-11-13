import Foundation
import SwiftUI

struct StatusTextModifier: ViewModifier {
    let status: String
    func body(content: Content) -> some View {
        content
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.18))
                    .overlay(Capsule().stroke(statusColor.opacity(0.5), lineWidth: 1))
            )
            .foregroundColor(statusColor)
    }
    
    private var statusColor: Color {
        (status.lowercased() == "active") || (status.lowercased() == "instock") ? .green : .red
    }
}

extension View {
    func customStatusStyle(status: String) -> some View {
        modifier(StatusTextModifier(status: status))
    }
}

