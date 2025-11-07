import SwiftUI

struct OwnerCOView: View {
    @State private var viewModel = OwnerPHListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                FilterSortBar(showFilterSheet: $viewModel.showFilterSheet, showSortSheet: $viewModel.showSortSheet)
                
                List {
                    ForEach(["CO 1", "CO 2", "CO 3", "CO 4"], id: \.self) { name in
                        Text(name)
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $viewModel.searchText, prompt: "Search Central Officer")
            }
            .navigationTitle("Central Office")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddSheet = true
                    } label: {
                        Text("Add +")
                            .fontWeight(.bold)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showFilterSheet) {
                FilterListSheetView(filters: [
                    "Location" : ["Pune", "Mumbai", "Delhi"]
                ])
            }
            .sheet(isPresented: $viewModel.showSortSheet) {
                SortListSheetView(sortOptions: [
                    "Alphabetically A-Z"
                ])
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddCentralOfficerView()
            }
        }
    }
}

#Preview {
    OwnerCOView()
}
