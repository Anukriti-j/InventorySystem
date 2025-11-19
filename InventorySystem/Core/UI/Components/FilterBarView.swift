import Foundation
import SwiftUI

struct FiltersBarView: View {
    let filters: [String: [String]]
    @Binding var selections: [String: Set<String>]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                
                ForEach(filters.keys.sorted(), id: \.self) { key in
                    MultiSelectFilterMenu(
                        title: key,
                        options: filters[key] ?? [],
                        selections: Binding(
                            get: { selections[key] ?? [] },
                            set: { selections[key] = $0 }
                        )
                    )
                }
                
                if selections.values.contains(where: { !$0.isEmpty }) {
                    Button("Clear") {
                        clearAll()
                    }
                    .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func clearAll() {
        for key in filters.keys {
            selections[key] = []
        }
    }
}
