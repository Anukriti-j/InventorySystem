import SwiftUI

struct PlantHeadListView: View {
    @State private var viewModel = PlantHeadListViewModel()

    var body: some View {
        NavigationStack {
            filterAndSortBar
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: viewModel.appliedFilters)
            plantHeadList
                .navigationTitle("PlantHeads")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add +") {
                            viewModel.showAddSheet = true
                        }
                        .fontWeight(.semibold)
                    }
                }
                .task {
                    await viewModel.fetchPlantHeads(reset: true)
                }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddPlantHeadView()
        }
        .alert("Delete PlantHead", isPresented: $viewModel.showDeletePopUp) {
            Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
            Button("Delete", role: .destructive) {
                Task { await viewModel.confirmDelete() }
            }
        } message: {
            Text("Are you sure you want to delete this Planthead?")
        }
        .alert("Message", isPresented: $viewModel.showAlert) {
            Button("OK") {
                viewModel.showAlert = false
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }
}

extension PlantHeadListView {
    private var filterAndSortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                FiltersBarView(
                    filters: [
                        "Status": ["Inactive", "Active"]
                    ],
                    selections: Binding(
                        get: { viewModel.appliedFilters },
                        set: { updated in
                            viewModel.appliedFilters = updated
                            Task { await viewModel.applyFilters(updated) }
                        }
                    )
                )
                
                Spacer()
                
                SortMenuView(
                    title: "Sort",
                    options: [
                        "Sort by Name A-Z",
                        "Sort by Name Z-A"
                    ],
                    selection: Binding(
                        get: { viewModel.selectedSort },
                        set: { newValue in
                            viewModel.selectedSort = newValue
                            Task { await viewModel.applySort(newValue) }
                        }
                    )
                )
            }
        }
        .frame(height: 40)
        .padding(.top, 8)
    }
    
    private var plantHeadList: some View {
        ZStack {
            if viewModel.isLoading && viewModel.plantHeads.isEmpty {
                ProgressView("Loading officers...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if viewModel.plantHeads.isEmpty {
                emptyStateView

            } else {
                List {
                    ForEach(viewModel.plantHeads) { planthead in
                        PlantHeadCardView(viewModel: viewModel, plantHead: planthead)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .task {
                                await viewModel.loadNextPageIfNeeded(currentItem: planthead)
                            }
                    }

                    paginationFooter
                }
                .listStyle(.plain)
                .refreshable {
                    Task {
                        await viewModel.fetchPlantHeads(reset: true)
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search plantheads")
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("No PlantHeads")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Tap 'Add +' to create one.")
                .font(.subheadline)
                .foregroundColor(.gray)
            Button("Retry") {
                Task { await viewModel.fetchPlantHeads(reset: true) }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var paginationFooter: some View {
        Group {
            if viewModel.isLoading && viewModel.currentPage < viewModel.totalPages {
                ProgressView("Loading more…")
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            } else if viewModel.currentPage >= viewModel.totalPages {
                Text("All PlantHeads loaded")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            }
        }
    }
}
