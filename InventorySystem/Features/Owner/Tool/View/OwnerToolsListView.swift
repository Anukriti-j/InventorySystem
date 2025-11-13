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
           //  TOOLBAR MOVED HERE — DIRECTLY ON THE CONTENT
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
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.inline)
            .task { await loadInitialData() }
            
            // ────── Alerts ──────
            .alert("Delete Tool", isPresented: $viewModel.showDeletePopUp) {
                Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.confirmDelete() }
                }
            } message: { Text("Are you sure you want to delete this tool?") }
            
            .alert(viewModel.alertMessage ?? "Error", isPresented: $viewModel.showAlert) {
                Button("OK") {}
            }
        }
        
        // ────── Sheets (outside NavigationStack) ──────
        .sheet(isPresented: $viewModel.showFilterSheet) {
            FilterListSheetView(
                filters: viewModel.filterOptions,
                preselected: viewModel.appliedFilters
            ) { selectedFilters in
                Task {
                    await viewModel.applyFilters(selectedFilters)
                }
                dismiss()
            }
        }
        .sheet(isPresented: $viewModel.showSortSheet) {
            SortListSheetView(sortOptions: viewModel.sortOptions) { selectedSort in
                Task {
                    await viewModel.applySort(selectedSort)
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) { AddToolView() }
        .sheet(isPresented: $viewModel.showEditSheet) {
            if let t = viewModel.editingTool { EditToolView(tool: t) }
        }
    }
    
    // MARK: - Subviews
    private var filterAndSortBar: some View {
        FilterSortBar(
            showFilterSheet: $viewModel.showFilterSheet,
            showSortSheet: $viewModel.showSortSheet
        )
        .padding(.horizontal, 8)
    }
    
    private var toolList: some View {
        List {
            if viewModel.isLoading && viewModel.tools.isEmpty {
                ProgressView("Loading tools...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            else if viewModel.tools.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "wrench.and.screwdriver.fill")
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
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            else {
                ForEach(viewModel.tools) { tool in
                    ToolInfoCardView(viewModel: viewModel, tool: tool)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .task { await viewModel.loadNextPageIfNeeded(currentItem: tool) }
                }
                
                if viewModel.isLoading && viewModel.currentPage < viewModel.totalPages {
                    ProgressView("Loading more…")
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                } else if viewModel.currentPage >= viewModel.totalPages {
                    Text("All tools loaded")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.fetchTools(reset: true)
        }
        .searchable(text: $viewModel.searchText)
    }
    
    private func loadInitialData() async {
        await viewModel.loadInitialData()
    }
}
