import Foundation
import SwiftUI

struct MultiSelectFilterMenu: View {
    let title: String
    let options: [String]
    
    @Binding var selections: Set<String>
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    toggle(option)
                } label: {
                    Label(
                        option,
                        systemImage: selections.contains(option)
                        ? "checkmark.square.fill"
                        : "square"
                    )
                }
            }
        } label: {
            HStack {
                Text(title)
                if !selections.isEmpty {
                    Text("(\(selections.count))")
                        .foregroundColor(.blue)
                }
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial)
            .cornerRadius(8)
        }
    }
    
    private func toggle(_ value: String) {
        if selections.contains(value) {
            selections.remove(value)
        } else {
            selections.insert(value)
        }
    }
}
