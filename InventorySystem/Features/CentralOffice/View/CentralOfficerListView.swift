import SwiftUI

struct CentralOfficerListView: View {
    @State private var viewModel = CentralOfficerViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                filterAndSortBar
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: viewModel.appliedFilters)

                centralOfficerList
            }
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
}

extension CentralOfficerListView {
    private var filterAndSortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                FiltersBarView(
                    filters: ["Status": ["Active", "Inactive"]],
                    selections: Binding(
                        get: { viewModel.appliedFilters },
                        set: { viewModel.appliedFilters = $0.filter { !$0.value.isEmpty } }
                    )
                )
                .onChange(of: viewModel.appliedFilters) { _ ,_ in
                    Task { await viewModel.applyFilters(viewModel.appliedFilters) }
                }

                Spacer(minLength: 20)

                SortMenuView(
                    title: "Sort",
                    options: ["Sort by Name A-Z", "Sort by Name Z-A"],
                    selection: Binding(
                        get: { viewModel.selectedSort },
                        set: { newValue in
                            viewModel.selectedSort = newValue
                            Task { await viewModel.applySort(newValue) }
                        }
                    )
                )
            }
            .padding(.horizontal)
        }
        .frame(height: 50)
        .padding(.top, 8)
    }

    private var centralOfficerList: some View {
        ZStack {
            if viewModel.isLoading && viewModel.centralOfficers.isEmpty {
                ProgressView("Loading officers...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if viewModel.centralOfficers.isEmpty {
                VStack(spacing: 16) {
                    Text("No Central Officers")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Tap 'Add +' to create one.")
                        .foregroundColor(.gray)
                    Button("Retry") {
                        Task { await viewModel.fetchCentralOfficer(reset: true) }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                List {
                    ForEach(viewModel.centralOfficers) { officer in
                        CentralOfficerCardView(viewModel: viewModel, officer: officer)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .task {
                                await viewModel.loadNextPageIfNeeded(currentItem: officer)
                            }
                    }

                    if viewModel.isLoading && viewModel.currentPage < viewModel.totalPages {
                        ProgressView("Loading more...")
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                    else if viewModel.currentPage >= viewModel.totalPages {
                        Text("All officers loaded")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.fetchCentralOfficer(reset: true)
                }
            }
        }
        .searchable(text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search officers...")
        .onChange(of: viewModel.searchText) { _, newValue in
            viewModel.updateSearchText(newValue)
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
}
