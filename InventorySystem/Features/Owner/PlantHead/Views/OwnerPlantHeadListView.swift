import SwiftUI

struct OwnerPlantHeadListView: View {
    @State private var viewModel = OwnerPHListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                FilterSortBar(showFilterSheet: $viewModel.showFilterSheet, showSortSheet: $viewModel.showSortSheet)
                
                List {
                    ForEach(["PH 1", "PH 2", "PH 3", "PH 4"], id: \.self) { name in
                        Text(name)
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $viewModel.searchText, prompt: "Search Plant Head")
            }
            .navigationTitle("Plant Heads")
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
                AddPlantHeadView()
            }
        }
    }
}

#Preview {
    OwnerPlantHeadListView()
}
