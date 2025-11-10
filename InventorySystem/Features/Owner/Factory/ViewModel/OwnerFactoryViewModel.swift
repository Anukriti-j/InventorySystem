import Foundation

@MainActor
@Observable
final class OwnerFactoryViewModel {
    // MARK: - UI state
    var searchText: String = ""
    var showfilterSheet: Bool = false
    var showSortSheet: Bool = false
    var selectedSort: String? = nil
    var showFactoryDetail: Bool = false
    var showAddSheet: Bool = false
    var showEditSheet: Bool = false
    var showDeletePopUp: Bool = false
    var factoryIdToDelete: Int? = nil
    
    // MARK: - Data
    var factories: [Factory] = []
    var appliedFilters: [String: Set<String>] = [:]
    
    // MARK: - Pagination
    var isLoading = false
    var currentPage = 0
    var totalPages = 1
    
    // MARK: - Alerts
    var showAlert = false
    var alertMessage: String?
    
    let plantHeads: [(id: Int, name: String)] = [
        (1, "John Doe"),
        (2, "Amit Sharma"),
        (3, "Priya Nair"),
        (4, "David Wilson")
    ]
    
    // MARK: - Search debounce
    private var searchTask: Task<Void, Never>? = nil
    private let pageSize = 10
    
    // MARK: - Public API
    
    func fetchFactories(
        reset: Bool = false
    ) async {
        // prevent concurrent fetches
        guard !isLoading else { return }
        
        if reset {
            factories = []
            currentPage = 0
        } else {
            // If no more pages, stop
            if currentPage >= totalPages {
                return
            }
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Extract filter params
            // Convert sets to comma-separated strings if backend expects comma-separated values
            // Normalize filters before sending to API
            let locationParam = (appliedFilters["Location"] ?? [])
                .map { $0.capitalized } // optional normalization for cities
                .joined(separator: ",")
            
            let statusParam = (appliedFilters["Status"] ?? [])
                .map {
                    switch $0.lowercased() {
                    case "active": return "ACTIVE"
                    case "inactive": return "INACTIVE"
                    default: return $0.uppercased()
                    }
                }
                .joined(separator: ",")
            
            // Map selectedSort to backend fields
            let (sortByParam, sortDirectionParam) = mapSortToParams(selectedSort)
            
            // searchText: use nil if empty
            let searchParam = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : searchText
            
            // Call service (page is currentPage)
            let response = try await OwnerFactoryService.shared.fetchFactories(
                page: currentPage,
                size: pageSize,
                sortBy: sortByParam,
                sortDirection: sortDirectionParam,
                search: searchParam,
                status: statusParam.isEmpty ? nil : statusParam
            )
            totalPages = response.pagination.totalPages
            
            // Append data and increment page
            // Use reassignment to ensure UI updates
            let newItems = response.data
            if reset {
                factories = newItems
                currentPage = 1
            } else {
                factories = factories + newItems
                currentPage += 1
            }
            
        } catch {
            showAlert(with: "Cannot fetch factories: \(error.localizedDescription)")
        }
    }
    
    /// Called when user scrolls near bottom. Safely triggers next page if available.
    func loadNextPageIfNeeded(currentItem: Factory?) async {
        guard let currentItem = currentItem else { return }
        // threshold: when currentItem is the last item
        guard factories.last?.id == currentItem.id else { return }
        guard !isLoading else { return }
        guard currentPage < totalPages else { return }
        await fetchFactories()
    }
    
    /// Apply new filters and reload from first page
    func applyFilters(_ filters: [String: Set<String>]) async {
        appliedFilters = filters
        await fetchFactories(reset: true)
    }
    
    /// Apply a sort option (UI string), reload
    func applySort(_ sortOption: String?) async {
        selectedSort = sortOption
        await fetchFactories(reset: true)
    }
    
    /// Called from view when search text changes — debounced
    func updateSearchText(_ newText: String) {
        searchTask?.cancel()
        searchText = newText
        
        // Debounce 300ms
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300 * 1_000_000) // 300ms
            guard !Task.isCancelled else { return }
            await self?.fetchFactories(reset: true)
        }
    }
    
    // MARK: - Helpers
    
    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        guard let sort = sort else { return (nil, nil) }
        switch sort {
        case "Newest First":
            return ("createdAt", "desc")
        case "Oldest First":
            return ("createdAt", "asc")
        case "Production High → Low":
            return ("production", "desc")
        case "Production Low → High":
            return ("production", "asc")
        default:
            return (nil, nil)
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
    func prepareDelete(factoryId: Int) {
        factoryIdToDelete = factoryId
        showAlert = true
    }
    
    func cancelDelete() {
        showAlert = false
        factoryIdToDelete = nil
    }
    
    func confirmDelete() async {
        guard let id = factoryIdToDelete else { return }
        await deleteFactory(id: id)
        cancelDelete()
    }

    func deleteFactory(id: Int) async {
        factories.removeAll { $0.id == id }
        print("deleted factory called")
        do {
            let response = try await OwnerFactoryService.shared.deleteFactory(factoryID: id)
            print(response)
            showAlert(with: response.message)
        } catch {
            showAlert(with: "Could not delete factory: \(error.localizedDescription)")
        }
    }
}
