import SwiftUI

struct OwnerToolsListView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = OwnerToolsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                filterAndSortBar
                toolList
            }
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { addToolToolbar }
            .task { await loadInitialData() }
            
            // Delete confirmation alert
            .alert("Alert", isPresented: $viewModel.showDeletePopUp) {
                Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.confirmDelete() }
                }
            } message: {
                Text("Are you sure you want to delete the selected tool?")
            }
        }
        // Filter sheet
        .sheet(isPresented: $viewModel.showFilterSheet) {
            FilterListSheetView(
                filters: [
                    "Location": ["Pune", "Mumbai", "Delhi"],
                    "Status": ["Available", "In Use", "Maintenance"]
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
                    "Sort by Factory A-Z",
                    "Sort by Factory Z-A"
                ]
            ) { chosenSort in
                Task { await viewModel.applySort(chosenSort) }
            }
        }
        
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddToolView()
        }
    }
}

extension OwnerToolsListView {
    
    // MARK: - UI Components
    
    private var filterAndSortBar: some View {
        FilterSortBar(
            showFilterSheet: $viewModel.showFilterSheet,
            showSortSheet: $viewModel.showSortSheet
        )
        .padding(.horizontal, 8)
    }
    
    private var toolList: some View {
        ZStack {
            if viewModel.isLoading && viewModel.tools.isEmpty {
                ProgressView("Loading tools...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.tools.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "gear")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No tools found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Try adjusting your filters or search criteria.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.tools) { tool in
                        Button {
                            viewModel.showToolDetail = true
                        } label: {
                            ToolInfoCardView(
                                viewModel: viewModel,
                                tool: tool
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .task {
                            await viewModel.loadNextPageIfNeeded(currentItem: tool)
                        }
                    }
                    
                    if viewModel.isLoading && !viewModel.tools.isEmpty && viewModel.currentPage < viewModel.totalPages {
                        ProgressView("Loading more…")
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    } else if !viewModel.isLoading && viewModel.currentPage >= viewModel.totalPages {
                        Text("All tools loaded")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    Task { await viewModel.fetchTools(reset: true) }
                }
            }
        }
        .alert(viewModel.alertMessage ?? "Message", isPresented: $viewModel.showAlert) {
            Button("OK") {
                dismiss()
            }
        }
        .searchable(text: $viewModel.searchText)
    }
    
    private var addToolToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.showAddSheet = true
            } label: {
                Text("Add +")
                    .fontWeight(.bold)
            }
        }
    }
    
    private func loadInitialData() async {
        await viewModel.fetchTools(reset: true)
    }
}

