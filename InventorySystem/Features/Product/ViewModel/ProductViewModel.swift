import Foundation
import SwiftUI

@MainActor
@Observable
final class ProductsViewModel {
    var searchText = ""
    var showAddSheet = false
    var showEditSheet = false
    var showDeletePopUp = false
    var editingProduct: Product?
    private var productIdToDelete: Int?

    var products: [Product] = []
    var categories: [ProductCategory] = []
    var appliedFilters: [String: Set<String>] = [:]
    var selectedSort: String?

    var isLoading = false
    var currentPage = 0
    var totalPages = 1
    private let pageSize = 10

    var showAlert = false
    var alertMessage: String?

    private var searchDebounceTask: Task<Void, Never>?

    // MARK: - Initial Load
    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.getProductCategories() }
            group.addTask { await self.fetchProducts(reset: true) }
        }
    }

    private func getProductCategories() async {
        do {
            let response = try await ProductService.shared.getProductCategories()
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

        let categoryNames = appliedFilters["Category"]?.isEmpty == false
            ? Array(appliedFilters["Category"]!).joined(separator: ",")
            : nil

        let availability: String? = {
            let set = appliedFilters["Availability"] ?? []
            if set.contains("In Stock") && !set.contains("Out of Stock") { return "InStock" }
            if set.contains("Out of Stock") && !set.contains("In Stock") { return "OutOfStock" }
            return nil
        }()

        let (sortBy, sortDir) = mapSortToParams(selectedSort)

        let searchQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchParam = searchQuery.isEmpty ? nil : searchQuery

        do {
            let response = try await ProductService.shared.fetchProducts(
                categoryNames: categoryNames,
                availability: availability,
                page: currentPage,
                size: pageSize,
                sortBy: sortBy,
                sortDir: sortDir,
                search: searchParam
            )

            totalPages = response.pagination.totalPages
            let newProducts = response.data

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

    // MARK: - SEARCH (NOW 100% WORKING)
    func updateSearchText(_ text: String) {
        searchText = text
        searchDebounceTask?.cancel()
        searchDebounceTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await self.fetchProducts(reset: true)
        }
    }

    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        guard let sort = sort else { return (nil, nil) }
        switch sort {
        case "Name A to Z":           return ("name", "asc")
        case "Name Z to A":           return ("name", "desc")
        case "Price High to Low":     return ("price", "desc")
        case "Price Low to High":     return ("price", "asc")
        case "Stock High to Low":     return ("quantity", "desc")
        case "Stock Low to High":     return ("quantity", "asc")
        default:                      return (nil, nil)
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
            let resp = try await ProductService.shared.deleteProduct(productID: id)
            showAlert(message: resp.message)
        } catch {
            showAlert(message: "Failed to delete product")
        }
        cancelDelete()
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
