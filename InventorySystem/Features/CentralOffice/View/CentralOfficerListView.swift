import SwiftUI

struct CentralOfficerListView: View {
    @StateObject private var viewModel = CentralOfficerViewModel()

    var body: some View {
        NavigationStack {
            filterAndSortBar
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: viewModel.appliedFilters)
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
    }
}

extension CentralOfficerListView {
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
                            .listRowSeparator(Visibility.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
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
