import SwiftUI

struct ToolsListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionManager.self) private var session

    @State private var viewModel: ToolsListViewModel
    @State private var isRefreshing = false

    init(factoryId: Int? = nil, userRole: UserRole?) {
        _viewModel = State(wrappedValue: ToolsListViewModel(factoryId: factoryId, userRole: userRole))
    }

    var body: some View {
        NavigationStack {
            VStack {
                filterAndSortBar
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: viewModel.appliedFilters)
                toolList
            }
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let role = session.user?.userRole,
                       role == .owner || role == .plantHead {
                        Button("Add +") {
                            viewModel.showAddSheet = true
                        }
                        .fontWeight(.bold)
                    }
                }
            }
            .task { await viewModel.loadInitialData() }
            .refreshable { await viewModel.fetchTools(reset: true) }
            .alert("Delete Tool", isPresented: $viewModel.showDeletePopUp) {
                Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.confirmDelete() }
                }
            } message: { Text("Are you sure you want to delete this tool?") }

            .alert(viewModel.alertMessage ?? "Error", isPresented: $viewModel.showAlert) {
                Button("OK") { }
            }

            .sheet(isPresented: $viewModel.showAddSheet) {
                AddToolView()
            }
            .sheet(isPresented: $viewModel.showEditSheet) {
                if let tool = viewModel.editingTool {
                    EditToolView(tool: tool)
                }
            }
        }
    }
}

// MARK: - Extensions
extension ToolsListView {
    private var filterAndSortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                if let role = session.user?.userRole, role == .owner {
                    FiltersBarView(
                        filters: [
                            "Factory": viewModel.factories.map { $0.factoryName },
                            "Category": viewModel.categories.map { $0.categoryName },
                            "Availability": ["In Stock", "Out of Stock"]
                        ],
                        selections: Binding(
                            get: { viewModel.appliedFilters },
                            set: { viewModel.appliedFilters = $0.filter { !$0.value.isEmpty } }
                        )
                    )
                    .onChange(of: viewModel.appliedFilters) { _ in
                        Task { await viewModel.applyFilters(viewModel.appliedFilters) }
                    }
                }
                else if let role = session.user?.userRole,
                        role == .plantHead || role == .chiefSupervisor {
                    FiltersBarView(
                        filters: [
                            "Category": viewModel.categories.map { $0.categoryName },
                            "Availability": ["In Stock", "Out of Stock"]
                        ],
                        selections: Binding(
                            get: { viewModel.appliedFilters },
                            set: { viewModel.appliedFilters = $0.filter { !$0.value.isEmpty } }
                        )
                    )
                    .onChange(of: viewModel.appliedFilters) { _ in
                        Task { await viewModel.applyFilters(viewModel.appliedFilters) }
                    }
                }

                Spacer()

                SortMenuView(
                    title: "Sort",
                    options: [
                        "Name A to Z",
                        "Name Z to A",
                        "Available Quantity High to Low",
                        "Available Quantity Low to High"
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

    private var toolList: some View {
        ZStack {
            if viewModel.isLoading && viewModel.allTools.isEmpty {
                ProgressView("Loading tools...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.allTools.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No tools found")
                        .font(.title3.bold())
                    Text("Try adjusting filters or search")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.allTools) { tool in
                        ToolInfoCardView(viewModel: viewModel, tool: tool)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .task { await viewModel.loadNextPageIfNeeded(currentItem: tool) }
                    }

                    if viewModel.isLoading {
                        ProgressView("Loading more...")
                            .frame(maxWidth: .infinity)
                    } else if viewModel.currentPage >= viewModel.totalPages {
                        Text("All tools loaded")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search tools by name...")
            .onChange(of: viewModel.searchText) { _, newValue in
                viewModel.updateSearchText(newValue)  
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
        .onChange(of: viewModel.searchText) { _, newValue in
            viewModel.updateSearchText(newValue)
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
}
