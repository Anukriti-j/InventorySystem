import SwiftUI

@MainActor
@Observable
final class OwnerToolsViewModel {
    // ────── UI state ──────
    var searchText = ""
    var showFilterSheet = false
    var showSortSheet   = false
    var showAddSheet    = false
    var showEditSheet   = false
    var showDeletePopUp = false
    var editingTool: Tool?
    private var toolIdToDelete: Int?

    // ────── Data ──────
    var tools: [Tool] = []
    var factories: [Factory] = []          // <-- new
    var categories: [ToolCategory] = []
    var appliedFilters: [String: Set<String>] = [:]
    var selectedSort: String?

    // ────── Pagination ──────
    var isLoading = false
    var currentPage = 0
    var totalPages = 1
    private let pageSize = 10

    // ────── Alerts ──────
    var showAlert = false
    var alertMessage: String?

    private var debounceTask: Task<Void, Never>?

    // ────── FILTER OPTIONS (shown in FilterListSheetView) ──────
    var filterOptions: [String: [String]] {
        [
            "Factory": factories.map { $0.factoryName },
            "Category": categories.map { $0.categoryName },
            "Availability": ["In Stock", "Out of Stock"]
        ]
    }

    let sortOptions = [
        "Name A to Z",
        "Name Z to A",
        "Quantity High to Low",
        "Quantity Low to High"
    ]

    // ────── INITIAL LOAD ──────
    func loadInitialData() async {
        await getFactories()
        await getCategories()
        await fetchTools(reset: true)
    }

    private func getFactories() async {
        do {
            let response = try await OwnerFactoryService.shared.fetchFactories(
                page: 0,
                size: 100,
                sortBy: nil,
                sortDirection: nil,
                search: nil,
                status: nil,
                location: nil
            )
            factories = response.data
        } catch {
            showAlert(message: "Failed to load factories for filtering")
        }
    }

    // ────── FETCH CATEGORIES ──────
    private func getCategories() async {
        do {
            let response = try await OwnerToolService.shared.getCategories()
            categories = response.data
        } catch {
            showAlert(message: "Failed to load categories")
        }
    }

    // ────── FETCH TOOLS ──────
    func fetchTools(reset: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        if reset {
            tools = []
            currentPage = 0
        }

        // ----- factory -----
        let factoryName = appliedFilters["Factory"]?.first
        let factoryId: Int? = factoryName.flatMap { name in
            factories.first { $0.factoryName == name }?.id
        }

        // ----- categories (comma-separated) -----
        let categoryNames = appliedFilters["Category"]?.joined(separator: ",")

        // ----- availability -----
        let availability: String? = {
            let set = appliedFilters["Availability"] ?? []
            if set.contains("In Stock") && !set.contains("Out of Stock") { return "InStock" }
            if set.contains("Out of Stock") && !set.contains("In Stock") { return "OutOfStock" }
            return nil
        }()

        // ----- sort -----
        let (sortByParam, sortDirParam) = mapSortToParams(selectedSort)

        do {
            let response = try await OwnerToolService.shared.fetchTools(
                factoryId: factoryId,
                categoryNames: categoryNames,
                availability: availability,
                page: currentPage,
                size: pageSize,
                sortBy: sortByParam,
                sortDir: sortDirParam,
                search: searchText.isEmpty ? nil : searchText
            )

            totalPages = response.pagination.totalPages
            let newTools = response.data

            if reset {
                tools = newTools
                currentPage = 1
            } else {
                tools += newTools
                currentPage += 1
            }
        } catch {
            showAlert(message: "Failed to load tools: \(error.localizedDescription)")
        }
    }

    // ────── SORT MAPPING (price & quantity) ──────
    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        guard let sort = sort else { return (nil, nil) }
        switch sort {
        case "Name A to Z":               return ("name", "asc")
        case "Name Z to A":               return ("name", "desc")
        case "Quantity High to Low":      return ("quantity", "desc")
        case "Quantity Low to High":      return ("quantity", "asc")
        default:                          return (nil, nil)
        }
    }

    // ────── PAGINATION ──────
    func loadNextPageIfNeeded(currentItem: Tool) async {
        guard tools.last?.id == currentItem.id,
              currentPage < totalPages,
              !isLoading else { return }
        await fetchTools()
    }

    // ────── FILTER / SORT APPLY ──────
    func applyFilters(_ filters: [String: Set<String>]) async {
        appliedFilters = filters.filter { !$0.value.isEmpty }
        await fetchTools(reset: true)
    }

    func applySort(_ sort: String?) async {
        selectedSort = sort
        await fetchTools(reset: true)
    }

    // ────── SEARCH DEBOUNCE ──────
    func updateSearchText(_ text: String) {
        searchText = text
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)   // 0.3 s
            await fetchTools(reset: true)
        }
    }

    // ────── DELETE ──────
    func prepareDelete(toolId: Int) {
        toolIdToDelete = toolId
        showDeletePopUp = true
    }

    func cancelDelete() {
        showDeletePopUp = false
        toolIdToDelete = nil
    }

    func confirmDelete() async {
        guard let id = toolIdToDelete else { return }
        tools.removeAll { $0.id == id }
        do {
            let resp = try await OwnerToolService.shared.deleteTool(toolID: id)
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
