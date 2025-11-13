import SwiftUI

@MainActor
@Observable
final class OwnerProductsViewModel {
    // UI State
    var searchText = ""
    var showFilterSheet = false
    var showSortSheet = false
    var showAddSheet = false
    var showEditSheet = false
    var showDeletePopUp = false
    var editingProduct: Product?
    private var productIdToDelete: Int?

    // Data
    var products: [Product] = []
    var categories: [ProductCategory] = []
    var appliedFilters: [String: Set<String>] = [:]
    var selectedSort: String?

    // Pagination
    var isLoading = false
    var currentPage = 0
    var totalPages = 1
    private let pageSize = 10

    // Alerts
    var showAlert = false
    var alertMessage: String?

    private var debounceTask: Task<Void, Never>?

    // MARK: - Filter & Sort Options
    var filterOptions: [String: [String]] {
        [
            "Category": categories.map { $0.categoryName },
            "Availability": ["In Stock", "Out of Stock"]
        ]
    }

    let sortOptions = [
        "Name A to Z",
        "Name Z to A",
        "Price High to Low",
        "Price Low to High",
        "Stock High to Low",
        "Stock Low to High"
    ]

    // MARK: - Load Initial
    func loadInitialData() async {
        await getProductCategories()
        await fetchProducts(reset: true)
    }

    private func getProductCategories() async {
        do {
            let response = try await OwnerProductService.shared.getProductCategories()
            categories = response.data
        } catch {
            showAlert(message: "Failed to load categories")
        }
    }

    // MARK: - Fetch Products
    func fetchProducts(reset: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        if reset {
            products = []
            currentPage = 0
        }

        let categoryNames = appliedFilters["Category"]?.joined(separator: ",")

        let availability: String? = {
            let set = appliedFilters["Availability"] ?? []
            if set.contains("In Stock") && !set.contains("Out of Stock") { return "InStock" }
            if set.contains("Out of Stock") && !set.contains("In Stock") { return "OutOfStock" }
            return nil
        }()

        let (sortBy, sortDir) = mapSortToParams(selectedSort)

        do {
            let response = try await OwnerProductService.shared.fetchProducts(
                categoryNames: categoryNames,
                availability: availability,
                page: currentPage,
                size: pageSize,
                sortBy: sortBy,
                sortDir: sortDir,
                search: searchText.isEmpty ? nil : searchText
            )

            totalPages = response.pagination.totalPages
            let newProducts = response.data  // ← Mapped to [Product]

            if reset {
                products = newProducts
                currentPage = 1
            } else {
                products += newProducts
                currentPage += 1
            }
        } catch {
            showAlert(message: "Failed to load products: \(error.localizedDescription)")
        }
    }

    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        guard let sort = sort else { return (nil, nil) }
        switch sort {
        case "Name A to Z":               return ("name", "asc")
        case "Name Z to A":               return ("name", "desc")
        case "Price High to Low":         return ("price", "desc")
        case "Price Low to High":         return ("price", "asc")
        case "Stock High to Low":         return ("quantity", "desc")
        case "Stock Low to High":         return ("quantity", "asc")
        default:                          return (nil, nil)
        }
    }

    // MARK: - Pagination
    func loadNextPageIfNeeded(currentItem: Product) async {
        guard products.last?.id == currentItem.id,
              currentPage < totalPages,
              !isLoading else { return }
        await fetchProducts()
    }

    // MARK: - Filters & Sort
    func applyFilters(_ filters: [String: Set<String>]) async {
        appliedFilters = filters.filter { !$0.value.isEmpty }
        await fetchProducts(reset: true)
    }

    func applySort(_ sort: String?) async {
        selectedSort = sort
        await fetchProducts(reset: true)
    }

    // MARK: - Search
    func updateSearchText(_ text: String) {
        searchText = text
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            await fetchProducts(reset: true)
        }
    }

    // MARK: - Delete
    func prepareDelete(productId: Int) {
        productIdToDelete = productId
        showDeletePopUp = true
    }

    func cancelDelete() {
        showDeletePopUp = false
        productIdToDelete = nil
    }

    func confirmDelete() async {
        guard let id = productIdToDelete else { return }
        products.removeAll { $0.id == id }
        do {
            let resp = try await OwnerProductService.shared.deleteProduct(productID: id)
            showAlert(message: resp.message)
        } catch {
            showAlert(message: "Failed to delete")
        }
        cancelDelete()
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
