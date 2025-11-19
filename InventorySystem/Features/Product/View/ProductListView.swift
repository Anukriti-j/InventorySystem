import SwiftUI

struct ProductsListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ProductsViewModel()
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
            .refreshable { await viewModel.fetchProducts(reset: true) }
            
            .alert("Delete Product", isPresented: $viewModel.showDeletePopUp) {
                Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.confirmDelete() }
                }
            } message: {
                Text("Are you 100% sure you want to delete this product?")
            }
            
            // General Alert
            .alert(viewModel.alertMessage ?? "Error", isPresented: $viewModel.showAlert) {
                Button("OK") {}
            }
            
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddProductView(parentViewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showEditSheet) {
                if let product = viewModel.editingProduct {
                    EditProductView(product: product)
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
                    Image(systemName: "cart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No products found")
                        .font(.title3.bold())
                    Text("Try adjusting filters or search")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}
