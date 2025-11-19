import Foundation

@Observable
final class FactoryWorkerDetailViewModel {
    var isLoading = false
    var workers: [Worker] = []
    
    var appliedFilters: [String: Set<String>] = [:]
    var searchText: String = ""
    var selectedSort: String? = nil
    
    private let pageSize = 10
    private var currentPage = 0
    private var totalPages = 1
    private var debounceTask: Task<Void, Never>?
    
    func fetchWorkers(reset: Bool = false) async {
        guard !isLoading else { return }
        
        if reset {
            workers = []
            currentPage = 0
        } else {
            guard currentPage < totalPages else { return }
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let locationFilter = appliedFilters["Location"]?.joined(separator: ",")
        let statusFilter = appliedFilters["Status"]?.joined(separator: ",")
        
        let searchParam = searchText.isEmpty ? nil : searchText
        
        let (sortBy, sortDir) = mapSort(selectedSort)
        
        do {
            let response = try await FactoryDetailService.shared.fetchFactoryWorkers(
                page: currentPage,
                size: pageSize,
                sortBy: sortBy,
                sortDirection: sortDir,
                search: searchParam,
                status: statusFilter, factoryId: 1
            )
            
            totalPages = response.pagination.totalPages
            
            if reset {
                workers = response.data
                currentPage = 1
            } else {
                workers += response.data
                currentPage += 1
            }
            
        } catch {
            print("Failed to fetch workers:", error)
        }
    }
    
    func applyFilters(_ filters: [String: Set<String>]) {
        appliedFilters = filters
        Task { await fetchWorkers(reset: true) }
    }
    
    func applySort(_ sort: String?) {
        selectedSort = sort
        Task { await fetchWorkers(reset: true) }
    }
    
    func updateSearch(_ text: String) {
        debounceTask?.cancel()
        searchText = text
        
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            await fetchWorkers(reset: true)
        }
    }
    
    private func mapSort(_ value: String?) -> (String?, String?) {
        switch value {
        case "Alphabetically A-Z":
            return ("name", "asc")
        case "Alphabetically Z-A":
            return ("name", "desc")
        default:
            return (nil, nil)
        }
    }
}
