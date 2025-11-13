import Foundation

@MainActor
final class OwnerCOViewModel: ObservableObject {
  
    @Published var showAlert = false
    @Published  var alertMessage: String?
    @Published var showAddSheet: Bool = false
    @Published var centralOfficers: [CentralOfficer] = []
    @Published var currentPage = 0
    @Published var totalPages = 1
    @Published var isLoading = false
    @Published var searchText: String = ""
    @Published var showfilterSheet: Bool = false
    @Published var showSortSheet: Bool = false
    @Published var selectedSort: String? = nil
    @Published var showDeletePopUp: Bool = false
    @Published var centralOfficerToDelete: Int? = nil
    
    private let pageSize = 10
    
    var appliedFilters: [String: Set<String>] = [:]
    
    private var debounceTask: Task<Void, Never>? = nil
   
    func fetchCentralOfficer(reset: Bool = false) async {
        guard !isLoading else {
            print("⏳ Skipping fetch — already loading")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        if reset {
            centralOfficers = []
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
            
            let response = try await OwnerCentralOfficeService.shared.fetchCentralOfficer(
                page: currentPage,
                size: pageSize,
                role: "centralofficer",
                sortBy: sortByParam,
                sortDirection: sortDirectionParam,
                search: searchParam,
                statuses: statusParam
            )
            totalPages = response.pagination.totalPages
            let newItems = response.data
            
            if reset {
                centralOfficers = newItems
                currentPage = 1
            } else {
                centralOfficers += newItems
                currentPage += 1
            }
        } catch {
            showAlert(with: "Cannot fetch Central Officer: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
    
    func loadNextPageIfNeeded(currentItem: CentralOfficer?) async {
        guard let currentItem = currentItem else { return }
        // threshold: when currentItem is the last item
        guard centralOfficers.last?.id == currentItem.id else { return }
        guard !isLoading else { return }
        guard currentPage < totalPages else { return }
        await fetchCentralOfficer()
    }
    
    func applyFilters(_ filters: [String: Set<String>]) async {
        debounceTask?.cancel()
        appliedFilters = filters.filter { !$0.value.isEmpty }

        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300 * 1_000_000) // 0.3s
            guard !Task.isCancelled else { return }
            await self?.fetchCentralOfficer(reset: true)
        }
    }
    
    func applySort(_ sortOption: String?) async {
        selectedSort = sortOption
        await fetchCentralOfficer(reset: true)
    }
    
    func updateSearchText(_ newText: String) {
        debounceTask?.cancel()
        searchText = newText
        
        // Debounce 300ms
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300 * 1_000_000) // 300ms
            guard !Task.isCancelled else { return }
            await self?.fetchCentralOfficer(reset: true)
        }
    }
    
    // MARK: - Helpers
    
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
    
    func prepareDelete(centralOfficerID: Int) {
        centralOfficerToDelete = centralOfficerID
        showDeletePopUp = true
    }
    
    func cancelDelete() {
        showAlert = false
        centralOfficerToDelete = nil
    }
    
    func confirmDelete() async {
        guard let id = centralOfficerToDelete else { return }
        await deleteCentralOfficer(id: id)
        cancelDelete()
    }
    
    func deleteCentralOfficer(id: Int) async {
        centralOfficers.removeAll { $0.id == id }
        
        do {
            let response = try await OwnerCentralOfficeService.shared.deleteCentralOfficer(id: id)
            showAlert(with: response.message)
        } catch {
            showAlert(with: "Could not delete factory: \(error.localizedDescription)")
        }
    }
    
    func refreshWithoutCancel() async {
        isLoading = false
        centralOfficers = []
        currentPage = 1
        totalPages = 1
        await fetchCentralOfficer(reset: true)
    }
}
