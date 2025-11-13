import SwiftUI

struct FilterListSheetView: View {
    @Environment(\.dismiss) private var dismiss

    let filters: [String: [String]]                // ["Location": ["Pune", "Mumbai"], "Status": ["Active", "Inactive"]]
    @State private var selectedFilter: String?
    @State private var selections: [String: Set<String>]
    
    var onApply: (([String: Set<String>]) -> Void)?
    
    // MARK: - Initializer supports preselected filters
    init(
        filters: [String: [String]],
        preselected: [String: Set<String>] = [:],
        onApply: (([String: Set<String>]) -> Void)? = nil
    ) {
        self.filters = filters
        self._selections = State(initialValue: preselected)
        self.onApply = onApply
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 0) {
                filterList
                Divider()
                filterValuesView
            }
            
            Divider()
            footerButtons
        }
        .padding()
        .onAppear(perform: initializeSelections)
    }
}

// MARK: - LEFT SIDEBAR (Filter Names)
extension FilterListSheetView {
    private var filterList: some View {
        List(filters.keys.sorted(), id: \.self) { key in
            Button {
                selectedFilter = key
            } label: {
                HStack {
                    Text(key)
                    Spacer()
                    
                    if let count = selections[key]?.count, count > 0 {
                        Text("(\(count))").foregroundColor(.blue)
                    }
                    
                    if selectedFilter == key {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .listRowInsets(.init(top: 12, leading: 8, bottom: 12, trailing: 0))
            .listRowBackground(
                selectedFilter == key ? Color.gray.opacity(0.15) : Color.clear
            )
        }
        .listStyle(.plain)
        .frame(width: 160)
    }
}

// MARK: - RIGHT SIDE (Values for selected filter)
extension FilterListSheetView {
    private var filterValuesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let filter = selectedFilter, let values = filters[filter] {
                Text(filter).font(.headline)
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(values, id: \.self) { value in
                            HStack {
                                Button {
                                    toggle(value, for: filter)
                                } label: {
                                    Image(systemName: isSelected(value, in: filter) ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 20))
                                }
                                .buttonStyle(.plain)
                                
                                Text(value)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
            } else {
                Text("Select a filter")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - FOOTER BUTTONS
extension FilterListSheetView {
    private var footerButtons: some View {
        HStack {
            Button("Clear All") {
                selections.removeAll()
                onApply?([:])
                dismiss()
            }
            .foregroundColor(.red)
            
            Spacer()
            
            Button("Apply") {
                onApply?(selections)
                dismiss()
            }
            .font(.headline)
        }
        .padding()
    }
}

// MARK: - Helpers
extension FilterListSheetView {
    
    private func initializeSelections() {
        // Only initialize missing keys (preserves preselected)
        for key in filters.keys {
            if selections[key] == nil {
                selections[key] = []
            }
        }
    }
    
    private func toggle(_ value: String, for filter: String) {
        var set = selections[filter, default: Set<String>()]
        
        if set.contains(value) {
            set.remove(value)
        } else {
            set.insert(value)
        }
        selections[filter] = set
    }
    
    private func isSelected(_ value: String, in filter: String) -> Bool {
        selections[filter]?.contains(value) ?? false
    }
}

#Preview {
    FilterListSheetView(
        filters: [
            "Location": ["Pune", "Mumbai", "Delhi"],
            "Category": ["IT", "Banking", "Design"],
            "Experience": ["Fresher", "1-3 Years", "3-5 Years", "5+ Years"]
        ],
        preselected: ["Location": ["Pune"], "Category": ["IT"]],
        onApply: { selected in
            print("Selected filters:", selected)
        }
    )
}
