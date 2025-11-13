import Foundation

@Observable
final class OwnerPlantHeadViewModel {
    var searchText: String = ""
    var showFilterSheet = false
    var showSortSheet = false
    var showAddSheet = false
    var isLoading = false
    var plantHeads: [PlantHead] = []
    var plantheadToDelete: Int?
    
    var currentPage = 0
    var totalPages = 1
    private let pageSize = 10
    
    var showAlert = false
    var alertMessage: String?
    var showDeletePopUp = false
    
    var appliedFilters: [String: Set<String>] = [:]
    var selectedSort: String? = nil
    
    private var debounceTask: Task<Void, Never>? = nil
    
    func fetchPlantHeads(reset: Bool = false) async {
        guard !isLoading else {
            print("⏳ Skipping fetch — already loading")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        if reset {
            plantHeads = []
            currentPage = 0
        } else {
            guard currentPage < totalPages else { return }
        }
        do {
            let statusParam: String? = {
                let statuses = (appliedFilters["Status"] ?? [])
                    .map { $0.uppercased() }
                return statuses.isEmpty ? nil : statuses.joined(separator: ",")
            }()
            
            let (sortByParam, sortDirectionParam) = mapSortToParams(selectedSort)
            let searchParam = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : searchText
            
            let response = try await OwnerPlantHeadService.shared.fetchPlantHeads (
                page: currentPage,
                size: pageSize,
                role: "planthead",
                sortBy: sortByParam,
                sortDirection: sortDirectionParam,
                search: searchParam,
                statuses: statusParam
            )
            totalPages = response.pagination.totalPages
            let newItems = response.data
            
            if reset {
                plantHeads = newItems
                currentPage = 1
            } else {
                plantHeads += newItems
                currentPage += 1
            }
        } catch {
            showAlert(with: "Cannot fetch PlantHeads: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
    
    func loadNextPageIfNeeded(currentItem: PlantHead?) async {
        guard let currentItem = currentItem else { return }
        guard plantHeads.last?.id == currentItem.id else { return }
        guard !isLoading else { return }
        guard currentPage < totalPages else { return }
        await fetchPlantHeads()
    }
    
    func applyFilters(_ filters: [String: Set<String>]) async {
        debounceTask?.cancel()
        appliedFilters = filters.filter { !$0.value.isEmpty }
        
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300 * 1_000_000) // 0.3s
            guard !Task.isCancelled else { return }
            await self?.fetchPlantHeads(reset: true)
        }
    }
    
    func applySort(_ sortOption: String?) async {
        selectedSort = sortOption
        await fetchPlantHeads(reset: true)
    }
    
    func updateSearchText(_ newText: String) {
        debounceTask?.cancel()
        searchText = newText
        
        // Debounce 300ms
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300 * 1_000_000) // 300ms
            guard !Task.isCancelled else { return }
            await self?.fetchPlantHeads(reset: true)
        }
    }
    
    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        guard let sort = sort else { return (nil, nil) }
        switch sort {
        case "Sort by Name A-Z":
            return ("username", "asc")
        case "Sort by Name Z-A":
            return ("username", "desc")
        default:
            return (nil, nil)
        }
    }
    
    func prepareDelete(plantheadId: Int) {
        plantheadToDelete = plantheadId
        showDeletePopUp = true
    }
    
    func cancelDelete() {
        showAlert = false
        plantheadToDelete = nil
    }
    
    func confirmDelete() async {
        guard let id = plantheadToDelete else { return }
        await deletePlantHead(id: id)
        cancelDelete()
    }
    
    func deletePlantHead(id: Int) async {
        plantHeads.removeAll { $0.id == id }
        
        do {
            let response = try await OwnerCentralOfficeService.shared.deleteCentralOfficer(id: id)
            showAlert(with: response.message)
        } catch {
            showAlert(with: "Could not delete factory: \(error.localizedDescription)")
        }
    }
    
    func refreshWithoutCancel() async {
        isLoading = false
        plantHeads = []
        currentPage = 1
        totalPages = 1
        await fetchPlantHeads(reset: true)
    }
}


