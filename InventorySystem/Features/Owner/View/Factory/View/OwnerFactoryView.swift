import Foundation
import SwiftUI

struct OwnerFactoryView: View {
    @State private var viewModel = OwnerFactoryViewModel()
    
    var body: some View {
        NavigationStack {
            
            VStack {
                FilterSortBar(showFilterSheet: $viewModel.showfilterSheet, showSortSheet: $viewModel.showSortSheet)
                
                List {
                    ForEach(0..<5) { _ in
                        Button {
                            viewModel.showFactoryDetail = true
                        } label: {
                            FactoryInfoCardView(
                                viewModel: viewModel,
                                title: "Factory 1",
                                subtitle: "Pune",
                                infoRows: [
                                    ("Plant Head:", "Shreya Amanaganti"),
                                    ("Products:", "300"),
                                    ("Tools:", "230"),
                                    ("Workers:", "100")
                                ]
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .navigationDestination(isPresented: $viewModel.showFactoryDetail, destination: {
                    OwnerFactoryDetailView()
                })
                .listStyle(.plain)
                .searchable(text: $viewModel.searchText)
            }
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
        }
        .navigationTitle("Factories")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showfilterSheet) {
            FilterListSheetView(filters: [
                "Location": ["Pune", "Mumbai", "Delhi"],
                "Plant head": ["IT", "Banking", "Design"]
            ])
        }
        .sheet(isPresented: $viewModel.showSortSheet) {
            SortListSheetView(
                sortOptions: [
                    "Newest First",
                    "Oldest First",
                    "Production High → Low",
                    "Production Low → High"
                ]
            ) { chosenSort in
                viewModel.selectedSort = chosenSort
                print("Applied sort:", chosenSort ?? "none")
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddFactoryView()
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            EditFactoryView(
                factory: FactoryResponse(
                    id: 1,
                    name: "Farmhouse",
                    city: "Pune",
                    address: "Nyati tech park",
                    plantHeadID: 10
                ),
                plantHeads: viewModel.plantHeads
            )
            { updatedFactory in
                //                // ✅ Update backend or list state with new values
                //                viewModel.updateFactory(updatedFactory)
                //            }
            }
        }
        .alert("Alert", isPresented: $viewModel.showDeletePopUp) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                //TODO:  perform deletion
            }
        } message: {
            Text("Are you sure you want to delete the selection!")
        }
    }
}



#Preview {
    OwnerFactoryView()
}
