import Foundation

@MainActor
@Observable
final class OwnerToolsViewModel {
    // MARK: - UI state
    var searchText: String = ""
    var showFilterSheet: Bool = false
    var showSortSheet: Bool = false
    var selectedSort: String? = nil
    var showToolDetail: Bool = false
    var showAddSheet: Bool = false
    var showDeletePopUp: Bool = false
    var toolIdToDelete: Int? = nil
    
    // MARK: - Data
    var tools: [Tool] = []
    var appliedFilters: [String: Set<String>] = [:]
    
    // MARK: - Pagination
    var isLoading = false
    var currentPage = 0
    var totalPages = 1
    private let pageSize = 10
    
    // MARK: - Alerts
    var showAlert = false
    var alertMessage: String?
    
    private var debounceTask: Task<Void, Never>? = nil
    
    // MARK: - Public API
    
    func fetchTools(reset: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        if reset {
            tools = []
            currentPage = 0
        } else {
            guard currentPage < totalPages else { return }
        }
        
        do {
            let locationParam = (appliedFilters["Location"] ?? []).joined(separator: ",")
            let statusParam = (appliedFilters["Status"] ?? []).joined(separator: ",")
            let (sortBy, sortDirection) = mapSortToParams(selectedSort)
            //let searchParam = searchText.isEmpty ? nil : searchText
            
            let response = try await OwnerToolService.shared.fetchTools(
                location: locationParam.isEmpty ? nil : locationParam,
                status: statusParam.isEmpty ? nil : statusParam,
                page: currentPage,
                size: pageSize,
                sortBy: sortBy,
                sortDirection: sortDirection,
            )
            print(response.data)
            totalPages = response.pagination.totalPages
            let newItems = response.data
            
            if reset {
                tools = newItems
                currentPage = 1
            } else {
                tools += newItems
                currentPage += 1
            }
        } catch {
            showAlert(with: "Failed to load tools: \(error.localizedDescription)")
        }
    }
    
    func loadNextPageIfNeeded(currentItem: Tool?) async {
        guard let currentItem = currentItem,
              tools.last?.id == currentItem.id,
              !isLoading,
              currentPage < totalPages else { return }
        await fetchTools()
    }
    
    func applyFilters(_ filters: [String: Set<String>]) async {
        debounceTask?.cancel()
        appliedFilters = filters.filter { !$0.value.isEmpty }

        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await self?.fetchTools(reset: true)
        }
    }
    
    func applySort(_ sortOption: String?) async {
        selectedSort = sortOption
        await fetchTools(reset: true)
    }
    
    func updateSearchText(_ newText: String) {
        debounceTask?.cancel()
        searchText = newText
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await self?.fetchTools(reset: true)
        }
    }
    
    // MARK: - Delete
    
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
        await deleteTool(id: id)
        cancelDelete()
    }
    
    func deleteTool(id: Int) async {
        tools.removeAll { $0.id == id }
        do {
            let response = try await OwnerToolService.shared.deleteTool(toolID: id)
            showAlert(with: response.message)
        } catch {
            showAlert(with: "Could not delete tool: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    
    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        guard let sort = sort else { return (nil, nil) }
        switch sort {
        case "Sort by Name A-Z": return ("name", "asc")
        case "Sort by Name Z-A": return ("name", "desc")
        case "Sort by Factory A-Z": return ("factoryName", "asc")
        case "Sort by Factory Z-A": return ("factoryName", "desc")
        default: return (nil, nil)
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
