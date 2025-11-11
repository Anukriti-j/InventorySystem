import SwiftUI

struct SortListSheetView: View {
    @Environment(\.dismiss) var dismiss
    let sortOptions: [String]
    @State private var selectedSort: String? = nil
    
    //MARK: pass selected sort
    var onApply: ((String?) -> Void)?               // Pass back selected sort
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Sort By")
                .font(.title3.bold())
                .padding()
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(sortOptions, id: \.self) { option in
                        HStack {
                            Button {
                                selectedSort = option
                            } label: {
                                Image(systemName: selectedSort == option ? "largecircle.fill.circle" : "circle")
                                    .font(.system(size: 20))
                            }
                            .buttonStyle(.plain)
                            
                            Text(option)
                                .font(.body)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                    }
                }
                .padding(.top, 8)
            }
            
            Divider()
            
            footerButtons
        }
    }
}

// MARK: - Footer
extension SortListSheetView {
    private var footerButtons: some View {
        HStack {
            Button("Clear") {
                selectedSort = nil
            }
            .foregroundColor(.red)
            
            Spacer()
            
            Button("Apply") {
                onApply?(selectedSort)
                dismiss()
            }
            .font(.headline)
        }
        .padding()
    }
}

#Preview {
    SortListSheetView(
        sortOptions: [
            "Newest First",
            "Oldest First",
            "Production High → Low",
            "Production Low → High"
        ]
    ) { selected in
        print("Selected sort:", selected ?? "none")
    }
}
