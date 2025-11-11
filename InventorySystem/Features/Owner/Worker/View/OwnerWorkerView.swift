import SwiftUI

struct OwnerWorkerView: View {
    @State private var viewModel = OwnerWorkerViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                filterAndSortBar
                workerList
            }
            .navigationTitle("Workers")
            .navigationBarTitleDisplayMode(.inline)
            .task { await loadInitialData() }

//            .alert("Alert", isPresented: $viewModel.showDeletePopUp) {
//                Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
//                Button("Delete", role: .destructive) {
//                    Task { await viewModel.confirmDelete() }
//                }
//            } message: {
//                Text("Are you sure you want to delete this worker?")
//            }
//
//            .navigationDestination(isPresented: $viewModel.showWorkerDetail) {
//                OwnerWorkerDetailView()
//            }
        }

        // Filter sheet
        .sheet(isPresented: $viewModel.showfilterSheet) {
            FilterListSheetView(
                filters: [
                    "Location": ["Pune", "Mumbai", "Delhi"],
                    "Role": ["Supervisor", "Engineer", "Technician"]
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
                    "Sort by City Z-A",
                    "Sort by Role A-Z",
                    "Sort by Role Z-A"
                ]
            ) { chosenSort in
                Task { await viewModel.applySort(chosenSort) }
            }
        }
    }
}

// MARK: - UI Components
extension OwnerWorkerView {
    private var filterAndSortBar: some View {
        FilterSortBar(
            showFilterSheet: $viewModel.showfilterSheet,
            showSortSheet: $viewModel.showSortSheet
        )
        .padding(.horizontal, 8)
    }

    private var workerList: some View {
        ZStack {
            if viewModel.isLoading && viewModel.workers.isEmpty {
                ProgressView("Loading workers...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.workers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No workers found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Try adjusting your filters or search criteria.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.workers) { worker in
                        WorkerInfoCardView(
                            viewModel: viewModel,
                            worker: worker
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .task {
                            await viewModel.loadNextPageIfNeeded(currentItem: worker)
                        }
                    }

                    // Pagination
                    if viewModel.isLoading && !viewModel.workers.isEmpty && viewModel.currentPage < viewModel.totalPages {
                        ProgressView("Loading more…")
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    } else if !viewModel.isLoading && viewModel.currentPage >= viewModel.totalPages {
                        Text("All workers loaded")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.fetchWorkers(reset: true)
                }
            }
        }
        .searchable(text: $viewModel.searchText)
    }

    private func loadInitialData() async {
        await viewModel.fetchWorkers(reset: true)
    }
}
