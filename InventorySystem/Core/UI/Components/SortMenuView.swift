import SwiftUI

struct SortMenuView: View {
    let title: String
    let options: [String]
    @Binding var selection: String?
    
    var body: some View {
        Menu {
            // Clear option
            if selection != nil {
                Button("Clear Sort") {
                    selection = nil
                }
            }
            
            // Sort options
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    Label(
                        option,
                        systemImage: selection == option
                            ? "largecircle.fill.circle"
                            : "circle"
                    )
                }
            }
            
        } label: {
            HStack {
                Text(selection ?? title)     
                    .font(.subheadline)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial)
            .cornerRadius(8)
        }
    }
}
