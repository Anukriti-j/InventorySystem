import SwiftUI

struct ProductsListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ProductsViewModel()
    @State private var isRefreshing = false
    let userRole: UserRole?
    
    init(userRole: UserRole?) {
        self.userRole = userRole
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                filterAndSortBar
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: viewModel.appliedFilters)
                
                productList
            }
            .navigationTitle("Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if userRole == .owner {
                        Button("Add +") {
                            viewModel.showAddSheet = true
                        }
                        .fontWeight(.bold)
                    }
                }
            }
            .task { await viewModel.loadInitialData() }
            .refreshable {
                Task { await pullToRefresh()}
            }
            
            .alert("Delete Product", isPresented: $viewModel.showDeletePopUp) {
                Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.confirmDelete() }
                }
            } message: {
                Text("Are you 100% sure you want to delete this product?")
            }
            
            .alert(viewModel.alertMessage ?? "Error", isPresented: $viewModel.showAlert) {
                Button("OK") {}
            }
            
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddOrUpdateProductView(parentViewModel: viewModel, mode: .add)
            }
            .sheet(isPresented: $viewModel.showEditSheet) {
                if let product = viewModel.editingProduct {
                    AddOrUpdateProductView(parentViewModel: viewModel, mode: .edit, product: product)
                }
            }
        }
    }
}

extension ProductsListView {
    private var filterAndSortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
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
                .onChange(of: viewModel.appliedFilters) { _ , _ in
                    Task { await viewModel.applyFilters(viewModel.appliedFilters) }
                }
                
                Spacer()
                
                SortMenuView(
                    title: "Sort",
                    options: [
                        "Name A to Z",
                        "Name Z to A",
                        "Price High to Low",
                        "Price Low to High",
                        "Stock High to Low",
                        "Stock Low to High"
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
    
    private var productList: some View {
        ZStack {
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView("Loading products...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if viewModel.products.isEmpty {
                VStack(spacing: 16) {
                    
                    Text("No Products found")
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
            }
            else {
                List {
                    ForEach(viewModel.products) { product in
                        ProductInfoCardView(viewModel: viewModel, product: product)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .task { await viewModel.loadNextPageIfNeeded(currentItem: product) }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView("Loading more...").frame(maxWidth: .infinity)
                    }
                    else if viewModel.currentPage >= viewModel.totalPages {
                        Text("All products loaded")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search products...")
        .onChange(of: viewModel.searchText) { _, newValue in
            viewModel.updateSearchText(newValue)
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
    
    private func retryLoad() async {
        isRefreshing = true
        await viewModel.fetchProducts(reset: true)
        isRefreshing = false
    }
    
    private func pullToRefresh() async {
        await viewModel.refreshWithoutCancel()
    }
}
