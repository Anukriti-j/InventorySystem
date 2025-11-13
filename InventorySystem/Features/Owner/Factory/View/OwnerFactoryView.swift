import SwiftUI

struct OwnerFactoryView: View {
    @State private var viewModel = OwnerFactoryViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                filterAndSortBar
                factoryList
            }
            .navigationTitle("Factories")
            .navigationBarTitleDisplayMode(.inline)
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
            .task { await loadInitialData() } // Fetch initial data
            
            .alert("Alert", isPresented: $viewModel.showDeletePopUp) {
                Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.confirmDelete() }
                }
            } message: {
                Text("Are you sure you want to delete the selection!")
            }
            // Navigation to detail screen
            .navigationDestination(isPresented: $viewModel.showFactoryDetail) {
                OwnerFactoryDetailView()
            }
        }
        // Filter sheet
        .sheet(isPresented: $viewModel.showfilterSheet) {
            FilterListSheetView(
                filters: [
                    "Location": ["Pune", "Mumbai", "Delhi"],
                    "Status": ["Active", "Inactive"]
                ],
                preselected: viewModel.appliedFilters
            ) { selected in
                Task { await viewModel.applyFilters(selected) }
            }
        }
        
        // Sort sheet
        .sheet(isPresented: $viewModel.showSortSheet) {
            SortListSheetView(
                sortOptions: [
                    "Sort by Name A-Z",
                    "Sort by Name Z-A",
                    "Sort by City A-Z",
                    "Sort by City Z-A"
                ]
            ) { chosenSort in
                Task { await viewModel.applySort(chosenSort) }
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddFactoryView(ownerFactoryViewModel: viewModel)
        }
        .sheet(item: $viewModel.selectedFactory) { factory in
            EditFactoryView(factory: factory, factoryViewModel: viewModel)
        }
    }
}

extension OwnerFactoryView {
    
    private var filterAndSortBar: some View {
        FilterSortBar(
            showFilterSheet: $viewModel.showfilterSheet,
            showSortSheet: $viewModel.showSortSheet
        )
        .padding(.horizontal, 8)
    }
    
    private var factoryList: some View {
        ZStack {
            if viewModel.isLoading && viewModel.factories.isEmpty {
                ProgressView("Loading factories...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.factories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No factories found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Try adjusting your filters or search criteria.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.factories) { factory in
                        Button {
                            viewModel.showFactoryDetail = true
                        } label: {
                            FactoryInfoCardView(
                                viewModel: viewModel,
                                factory: factory
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .task {
                            await viewModel.loadNextPageIfNeeded(currentItem: factory)
                        }
                    }
                    
                    if viewModel.isLoading && !viewModel.factories.isEmpty && viewModel.currentPage < viewModel.totalPages {
                        ProgressView("Loading more…")
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    } else if !viewModel.isLoading && !viewModel.factories.isEmpty && viewModel.currentPage >= viewModel.totalPages {
                        Text("All factories loaded")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    Task {
                        await viewModel.fetchFactories(reset: true)
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText)
    }
    
    private func loadInitialData() async {
        await viewModel.fetchFactories(reset: true)
    }
}

struct FactoryInfoRow: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}
