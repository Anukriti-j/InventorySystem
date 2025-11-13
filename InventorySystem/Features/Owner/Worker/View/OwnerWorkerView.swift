import SwiftUI

struct OwnerWorkerView: View {
    @State private var viewModel = OwnerWorkerViewModel()
    @State private var isRefreshing = false          // <-- new

    var body: some View {
        NavigationStack {
            VStack {
                filterAndSortBar
                workerList
            }
            .navigationTitle("Workers")
            .navigationBarTitleDisplayMode(.inline)
            //.task { await loadInitialData() }
            .alert("Alert", isPresented: $viewModel.showDeletePopUp) {
                Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.confirmDelete() }
                }
            } message: {
                Text("Are you sure you want to delete this worker?")
            }

            // ----- GENERAL MESSAGE / ERROR -----
            .alert("Message", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {
                    viewModel.showAlert = false
                    viewModel.alertMessage = nil
                }
            } message: {
                Text(viewModel.alertMessage ?? "An unknown error occurred.")
            }
        }
        .onAppear {
            Task {
                await loadInitialData()
                await viewModel.getFactories(reset: true)
            }
        }
        .sheet(isPresented: $viewModel.showfilterSheet) {
            FilterListSheetView(
                filters: [
                    "Factory": viewModel.factories.map { $0.factoryName },
                    "Status": ["Inactive", "Active"]
                ],
                preselected: viewModel.appliedFilters
            ) { selected in
                Task { await viewModel.applyFilters(selected) }
            }
        }

        .sheet(isPresented: $viewModel.showSortSheet) {
            SortListSheetView(
                sortOptions: [
                    "Sort by Name A-Z",
                    "Sort by Name Z-A"
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
            // ----- LOADING (first page) -----
            if viewModel.isLoadingWorkers && viewModel.workers.isEmpty {
                ProgressView("Loading workers...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ----- EMPTY / ERROR STATE -----
            } else if viewModel.workers.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)

                    Text("No workers found")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Try adjusting your filters or search criteria.")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // ----- REFRESH BUTTON -----
                    Button {
                        Task { await retryLoad() }
                    } label: {
                        Label("Retry", systemImage: "arrow.clockwise")
                            .font(.callout.bold())
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(isRefreshing)
                    .opacity(isRefreshing ? 0.6 : 1.0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()

            // ----- LIST -----
            } else {
                List {
                    ForEach(viewModel.workers) { worker in
                        WorkerInfoCardView(viewModel: viewModel, worker: worker)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .task {
                                await viewModel.loadNextPageIfNeeded(currentItem: worker)
                            }
                    }

                    // ----- PAGINATION FOOTER -----
                    if viewModel.isLoadingWorkers && viewModel.currentPage < viewModel.totalPages {
                        ProgressView("Loading more…")
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    } else if viewModel.currentPage >= viewModel.totalPages {
                        Text("All workers loaded")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    Task {
                        await pullToRefresh()
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText)
    }

    // MARK: - Helpers

    private func loadInitialData() async {
        await viewModel.fetchWorkers(reset: true)
    }

    private func retryLoad() async {
        isRefreshing = true
        await viewModel.fetchWorkers(reset: true)
        isRefreshing = false
    }

    private func pullToRefresh() async {
        // **Important**: do NOT call `fetchWorkers(reset: true)` directly.
        // It would cancel any in-flight request because `isLoading` is true
        // while the refresh gesture is still active.
        await viewModel.refreshWithoutCancel()
    }
}
