import Foundation

@MainActor
@Observable
final class FactoryViewModel {
    var searchText: String = ""
    var showfilterSheet: Bool = false
    var showSortSheet: Bool = false
    var selectedSort: String? = nil
    var showFactoryDetail: Bool = false
    var showAddSheet: Bool = false
    var showDeletePopUp: Bool = false
    var factoryIdToDelete: Int? = nil
    var selectedFactory: Factory?
    var factoryToEdit: Factory? = nil
    var locations: [String] = []
    
    var factories: [Factory] = []
    var appliedFilters: [String: Set<String>] = [:]
    
    var isLoading = false
    var currentPage = 0
    var totalPages = 1
    
    var showAlert = false
    var alertMessage: String?
    var deleteSuccess = false
    
    private var debounceTask: Task<Void, Never>? = nil
    private let pageSize = 10
    
    func getLocations() async {
        do {
            let response = try await FactoryService.shared.getLocations()
            if response.success {
                locations = response.data
            }
        } catch {
            showAlert(with: "Cannot fetch locations: \(error)")
        }
    }
    
    func fetchFactories(reset: Bool = false) async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        if reset {
            factories = []
            currentPage = 0
        } else {
            guard currentPage < totalPages else { return }
        }
        
        do {
            let locationParam: String? = {
                let locs = (appliedFilters["Location"] ?? [])
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).capitalized }
                return locs.isEmpty ? nil : locs.joined(separator: ",")
            }()
            
            let statusParam: String? = {
                let statuses = (appliedFilters["Status"] ?? [])
                    .map { $0.uppercased() }
                return statuses.isEmpty ? nil : statuses.joined(separator: ",")
            }()
            
            let (sortByParam, sortDirectionParam) = mapSortToParams(selectedSort)
            let searchParam = searchText.isEmpty ? nil : searchText
            
            let response = try await FactoryService.shared.fetchFactories(
                page: currentPage,
                size: pageSize,
                sortBy: sortByParam,
                sortDirection: sortDirectionParam,
                search: searchParam,
                status: statusParam,
                location: locationParam
            )
            
            totalPages = response.pagination.totalPages
            
            let newItems = response.data
            
            if reset {
                factories = newItems
                currentPage = 1
            } else {
                factories += newItems
                currentPage += 1
            }
        } catch {
            showAlert(with: "Cannot fetch factories: \(error.localizedDescription)")
        }
    }
    
    func refreshWithoutCancel() async {
        factories = []
        currentPage = 0
        totalPages = 1
        isLoading = false
        await fetchFactories(reset: true)
    }
    
    func loadNextPageIfNeeded(currentItem: Factory?) async {
        guard let currentItem = currentItem else { return }
        guard factories.last?.id == currentItem.id else { return }
        guard !isLoading else { return }
        guard currentPage < totalPages else { return }
        await fetchFactories()
    }
    
    func applyFilters(_ filters: [String: Set<String>]) async {
        debounceTask?.cancel()
        appliedFilters = filters.filter { !$0.value.isEmpty }
        
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await self?.fetchFactories(reset: true)
        }
    }
    
    func applySort(_ sortOption: String?) async {
        selectedSort = sortOption
        await fetchFactories(reset: true)
    }
    
    func updateSearchText(_ newText: String) {
        debounceTask?.cancel()
        searchText = newText
        
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            await self?.fetchFactories(reset: true)
        }
    }
    
    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        guard let sort = sort else { return (nil, nil) }
        switch sort {
        case "Sort by Name A-Z": return ("name", "asc")
        case "Sort by Name Z-A": return ("name", "desc")
        case "Sort by City A-Z": return ("city", "asc")
        case "Sort by City Z-A": return ("city", "desc")
        default: return (nil, nil)
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
        do {
            let response = try await FactoryService.shared.deleteFactory(factoryID: id)
            if response.success { deleteSuccess = true }
            showAlert(with: response.message)
        } catch {
            showAlert(with: "Could not delete factory: \(error.localizedDescription)")
        }
    }
}
