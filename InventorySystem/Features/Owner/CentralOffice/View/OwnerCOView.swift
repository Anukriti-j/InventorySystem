import SwiftUI

struct OwnerCOView: View {
    @StateObject private var viewModel = OwnerCOViewModel()

    var body: some View {
        NavigationStack {
            FilterSortBar(showFilterSheet: $viewModel.showfilterSheet, showSortSheet: $viewModel.showSortSheet)
            centralOfficerList
                .navigationTitle("Central Officers")
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
                    await viewModel.fetchCentralOfficer(reset: true)
                }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddCentralOfficerView()
        }
        .alert("Delete Officer", isPresented: $viewModel.showDeletePopUp) {
            Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
            Button("Delete", role: .destructive) {
                Task { await viewModel.confirmDelete() }
            }
        } message: {
            Text("Are you sure you want to delete this officer?")
        }
        .alert("Message", isPresented: $viewModel.showAlert) {
            Button("OK") {
                viewModel.showAlert = false
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        .sheet(isPresented: $viewModel.showfilterSheet) {
            FilterListSheetView(
                filters: [
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

    private var centralOfficerList: some View {
        ZStack {
            if viewModel.isLoading && viewModel.centralOfficers.isEmpty {
                ProgressView("Loading officers...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if viewModel.centralOfficers.isEmpty {
                emptyStateView

            } else {
                List {
                    ForEach(viewModel.centralOfficers) { officer in
                        CentralOfficerCardView(viewModel: viewModel, officer: officer)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .task {
                                await viewModel.loadNextPageIfNeeded(currentItem: officer)
                            }
                    }

                    paginationFooter
                }
                .listStyle(.plain)
                .refreshable {
                    Task {
                        await viewModel.fetchCentralOfficer(reset: true)
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search officers")
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("No Central Officers")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Tap 'Add +' to create one.")
                .font(.subheadline)
                .foregroundColor(.gray)
            Button("Retry") {
                Task { await viewModel.fetchCentralOfficer(reset: true) }
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
                Text("All officers loaded")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            }
        }
    }
}
