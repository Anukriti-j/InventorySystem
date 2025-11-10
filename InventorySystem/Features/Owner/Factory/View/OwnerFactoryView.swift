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
            .toolbar { addFactoryToolbar }
            .task { await loadInitialData() } // Fetch initial data
            
            // Delete confirmation alert
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
                    "Newest First",
                    "Oldest First",
                    "Production High → Low",
                    "Production Low → High"
                ]
            ) { chosenSort in
                Task { await viewModel.applySort(chosenSort) }
            }
        }
        
        // Add factory sheet
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddFactoryView()
        }
    }
}

extension OwnerFactoryView {
    
    // MARK: - UI Components
    
    private var filterAndSortBar: some View {
        FilterSortBar(
            showFilterSheet: $viewModel.showfilterSheet,
            showSortSheet: $viewModel.showSortSheet
        )
        .padding(.horizontal, 8)
    }
    
    private var factoryList: some View {
        List {
            ForEach(viewModel.factories) { factory in
                Button {
                    viewModel.showFactoryDetail = true
                } label: {
                    FactoryInfoCardView(
                        viewModel: viewModel,
                        factoryID: factory.id,
                        factoryName: factory.factoryName,
                        location: factory.location,
                        infoRows: [
                            InfoRow(label: "Plant Head:", value: factory.plantHeadName),
                            InfoRow(label: "Total Products:", value: "\(factory.totalProducts)"),
                            InfoRow(label: "Total Workers:", value: "\(factory.totalWorkers)"),
                            InfoRow(label: "Total Tools:", value: "\(factory.totalTools)")
                        ]
                    )
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                .task {
                    await viewModel.loadNextPageIfNeeded(currentItem: factory)
                }
            }
            
            // Bottom loading indicator
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
        .overlay {
            if viewModel.isLoading && viewModel.factories.isEmpty {
                ProgressView("Loading factories...")
            }
        }
        .refreshable {
            await viewModel.fetchFactories(reset: true)
        }
        .searchable(text: $viewModel.searchText)
    }
    
    private var addFactoryToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.showAddSheet = true
            } label: {
                Text("Add +")
                    .fontWeight(.bold)
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadInitialData() async {
        await viewModel.fetchFactories(reset: true)
    }
}

// MARK: - Supporting Model

struct InfoRow: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

