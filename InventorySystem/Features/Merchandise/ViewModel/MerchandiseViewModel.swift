import Foundation

@MainActor
@Observable
final class MerchandiseViewModel {
    var merchandises: [Merchandise] = []
    var showAddSheet = false
    var showEditSheet = false
    var selectedMerchandise: Merchandise?
    var showDeleteAlert = false
    var merchandiseToDelete: Merchandise?
    var alertMessage: String?
    var showAlert = false
    var searchText = ""
    var appliedFilters: [String: Set<String>] = [:]
    var selectedSort: String?
    
    private var debounceTask: Task<Void, Never>?
    private let pageSize = 10
    var currentPage = 0
    var totalPages = 1
    var isLoading = false
    
    func fetchMerchandise(reset: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        if reset {
            merchandises = []
            currentPage = 0
        }
        
        let status = appliedFilters["Status"]?
            .map { $0.lowercased() == "active" ? "ACTIVE" : "INACTIVE" }
            .joined(separator: ",")
        
        let stockStatus: String? = {
            let set = appliedFilters["StockStatus"] ?? []
            if set.contains("In Stock") && !set.contains("Out of Stock") { return "InStock" }
            if set.contains("Out of Stock") && !set.contains("In Stock") { return "OutOfStock" }
            return nil
        }()
        
        let (sortBy, sortDirection) = mapSortToParams(selectedSort)
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : searchText
        
        do {
            let response = try await MerchandiseService.shared.fetchMerchandise(
                page: currentPage,
                size: pageSize,
                sortBy: sortBy,
                sortDirection: sortDirection,
                search: search,
                status: status,
                stockStatus: stockStatus
            )
            
            totalPages = response.pagination.totalPages
            
            if reset {
                merchandises = response.data
                currentPage = 1
            } else {
                merchandises.append(contentsOf: response.data)
                currentPage += 1
            }
        } catch {
            if !Task.isCancelled {
                showAlert(message: "Failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
        debounceReload()
    }
    
    func applyFilters(_ filters: [String: Set<String>]) async {
        appliedFilters = filters.filter { !$0.value.isEmpty }
        await fetchMerchandise(reset: true)
    }
    
    func applySort(_ sort: String?) async {
        selectedSort = sort
        await fetchMerchandise(reset: true)
    }
    
    private func debounceReload() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await fetchMerchandise(reset: true)
        }
    }
    
    func loadNextPageIfNeeded(currentItem: Merchandise) async {
        guard merchandises.last?.id == currentItem.id else { return }
        guard currentPage < totalPages, !isLoading else { return }
        await fetchMerchandise()
    }
    
    func requestDelete(_ item: Merchandise) {
        merchandiseToDelete = item
        showDeleteAlert = true
    }
    
    func confirmDelete() async {
        guard let item = merchandiseToDelete else { return }
        merchandises.removeAll { $0.id == item.id }
        do {
            let resp = try await MerchandiseService.shared.deleteMerchandise(merchandiseId: item.id)
            showAlert(message: resp.message)
        } catch {
            showAlert(message: "Delete failed")
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        switch sort {
        case "Reward Points High to Low": return ("rewardPoints", "desc")
        case "Reward Points Low to High": return ("rewardPoints", "asc")
        default: return (nil, nil)
        }
    }
}
