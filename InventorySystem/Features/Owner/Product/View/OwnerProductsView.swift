import SwiftUI

struct OwnerProductsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = OwnerProductsViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                filterAndSortBar
                productList
            }
            .navigationTitle("Products")
            .navigationBarTitleDisplayMode(.inline)
            .task { await loadInitialData() }

            // MARK: - Delete Alert
            .alert("Delete Product", isPresented: $viewModel.showDeletePopUp) {
                Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.confirmDelete() }
                }
            } message: {
                Text("Are you 100% sure you want to delete this product?")
            }

            // MARK: - General Alert
            .alert(viewModel.alertMessage ?? "Error", isPresented: $viewModel.showAlert) {
                Button("OK") {}
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showAddSheet = true
                } label: {
                    Text("Add +")
                        .fontWeight(.bold)
                }
            }
        }

        // MARK: - Sheets (All UNCOMMENTED & WORKING)
        .sheet(isPresented: $viewModel.showFilterSheet) {
            FilterListSheetView(
                filters: viewModel.filterOptions,
                preselected: viewModel.appliedFilters
            ) { selected in
                Task { await viewModel.applyFilters(selected) }
            }
        }
        .sheet(isPresented: $viewModel.showSortSheet) {
            SortListSheetView(sortOptions: viewModel.sortOptions) { selected in
                Task { await viewModel.applySort(selected) }
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddProductView()
        }
        .sheet(isPresented: $viewModel.showEditSheet) {
            if let product = viewModel.editingProduct {
                EditProductView(product: product)
            }
        }
    }

    private var filterAndSortBar: some View {
        FilterSortBar(
            showFilterSheet: $viewModel.showFilterSheet,
            showSortSheet: $viewModel.showSortSheet
        )
        .padding(.horizontal, 8)
    }

    private var productList: some View {
        List {
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView("Loading products...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            else if viewModel.products.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No products found")
                        .font(.headline)
                    Text("Try adjusting filters or search.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            else {
                ForEach(viewModel.products) { product in
                    ProductInfoCardView(viewModel: viewModel, product: product)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .task { await viewModel.loadNextPageIfNeeded(currentItem: product) }
                }

                if viewModel.isLoading && viewModel.currentPage < viewModel.totalPages {
                    ProgressView("Loading more…")
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                } else if viewModel.currentPage >= viewModel.totalPages {
                    Text("All products loaded")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .refreshable { await viewModel.fetchProducts(reset: true) }
        .searchable(text: $viewModel.searchText)
    }

    private func loadInitialData() async {
        await viewModel.loadInitialData()
    }
}
