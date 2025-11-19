import Foundation

@Observable
final class FactoryToolsDetailViewModel {
    
    var isLoading = false
    var tools: [Tool] = []
    
    var appliedFilters: [String: Set<String>] = [:]
    var searchText: String = ""
    var selectedSort: String? = nil
    
    private let pageSize = 10
    private var currentPage = 0
    private var totalPages = 1
    private var debounceTask: Task<Void, Never>?
    
    func fetchTools(reset: Bool = false) async {
        guard !isLoading else { return }
        
        if reset {
            tools = []
            currentPage = 0
        } else {
            guard currentPage < totalPages else { return }
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let category = appliedFilters["Category"]?.joined(separator: ",")
        let statusParam: String? = {
            let statuses = (appliedFilters["Status"] ?? [])
                .map { $0.uppercased() }
            return statuses.isEmpty ? nil : statuses.joined(separator: ",")
        }()
        let availability = appliedFilters["Availability"]?.joined(separator: ",")
        let searchParam = searchText.isEmpty ? nil : searchText
        let (sortBy, sortDir) = mapSort(selectedSort)
        
        do {
            let response = try await FactoryDetailService.shared.fetchFactoryTools(
                page: currentPage,
                size: pageSize,
                sortBy: sortBy,
                sortDirection: sortDir,
                search: searchParam, status: statusParam,
//                availability: availability,
//                category: category
            )
            
            totalPages = response.pagination.totalPages
            
            if reset {
                tools = response.data
                currentPage = 1
            } else {
                tools += response.data
                currentPage += 1
            }
            
        } catch {
            print("Failed to fetch tools:", error)
        }
    }
    
    func applyFilters(_ filters: [String: Set<String>]) {
        appliedFilters = filters
        Task { await fetchTools(reset: true) }
    }
    
    func applySort(_ sort: String?) {
        selectedSort = sort
        Task { await fetchTools(reset: true) }
    }
    
    func updateSearch(_ text: String) {
        debounceTask?.cancel()
        searchText = text
        
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            await fetchTools(reset: true)
        }
    }
    
    private func mapSort(_ value: String?) -> (String?, String?) {
        switch value {
        case "Price High to Low": return ("price", "desc")
        case "Price Low to High": return ("price", "asc")
        case "Quantity High to Low": return ("quantity", "desc")
        case "Quantity Low to High": return ("quantity", "asc")
        default: return (nil, nil)
        }
    }
}
