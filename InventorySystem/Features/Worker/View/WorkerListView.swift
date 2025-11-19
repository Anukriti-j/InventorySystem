// WorkerListView.swift
import SwiftUI

struct WorkerListView: View {
    @State private var viewModel: WorkerViewModel
    @State private var isRefreshing = false
    let userRole: UserRole?
    let factoryId: Int?
    
    init(factoryId: Int? = nil, userRole: UserRole?) {
        self.userRole = userRole
        self.factoryId = factoryId
        _viewModel = State(wrappedValue: WorkerViewModel(factoryId: factoryId, userRole: userRole))
    }
    
    var body: some View {
        VStack {
            filterAndSortBar
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: viewModel.appliedFilters)
            workerList
        }
        .navigationTitle("Workers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if userRole == .owner || userRole == .plantHead || userRole == .chiefSupervisor {
                    Button("Add Worker") {
                        viewModel.showAddSheet = true
                    }
                }
            }
        }
        .alert("Alert", isPresented: $viewModel.showDeletePopUp) {
            Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
            Button("Delete", role: .destructive) {
                Task { await viewModel.confirmDelete() }
            }
        } message: {
            Text("Are you sure you want to delete this worker?")
        }
        .alert("Message", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {
                viewModel.showAlert = false
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "An unknown error occurred.")
        }
        .onAppear {
            Task {
                await loadInitialData()
                if userRole == .owner {
                    await viewModel.getFactories(reset: true)
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddWorkerView(
                factoryId: factoryId,
                userRole: userRole ?? .worker,
                listViewModel: viewModel
            )
        }
    }
}

extension WorkerListView {
    private var filterAndSortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                FiltersBarView(
                    filters: {
                        var filters: [String: [String]] = ["Status": ["Active", "Inactive"]]
                        if viewModel.shouldShowFactoryFilter {
                            filters["Factory"] = viewModel.factories.map { $0.factoryName }
                        }
                        return filters
                    }(),
                    selections: Binding(
                        get: { viewModel.appliedFilters },
                        set: { updated in
                            viewModel.appliedFilters = updated
                            Task { await viewModel.applyFilters(updated) }
                        }
                    )
                )
                .onChange(of: viewModel.appliedFilters) { _ in
                    Task { await viewModel.fetchAllWorkers(reset: true) }
                }
                
                Spacer(minLength: 20)
                
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
            .padding(.horizontal)
        }
        .frame(height: 50)
        .padding(.top, 8)
    }
    
    private var workerList: some View {
        ZStack {
            if viewModel.isLoadingWorkers && viewModel.workers.isEmpty {
                ProgressView("Loading workers...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    if viewModel.isLoadingWorkers && viewModel.currentPage < viewModel.totalPages {
                        ProgressView("Loading more...")
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
                    Task { await pullToRefresh() }
                }
            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search workers...")
        .onChange(of: viewModel.searchText) { _, newValue in
            viewModel.updateSearchText(newValue)
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
    
    private func loadInitialData() async {
        await viewModel.fetchAllWorkers(reset: true)
    }
    
    private func retryLoad() async {
        isRefreshing = true
        await viewModel.fetchAllWorkers(reset: true)
        isRefreshing = false
    }
    
    private func pullToRefresh() async {
        await viewModel.refreshWithoutCancel()
    }
}
