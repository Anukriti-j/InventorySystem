import Foundation

@MainActor
@Observable
final class WorkerViewModel {
    var searchText = ""
    var selectedSort: String?
    var showWorkerDetail = false
    var showDeletePopUp = false
    var workerIdToDelete: Int?
    var factoryId: Int?
    var showAddSheet = false
    
    var workers: [Worker] = []
    var factories: [Factory] = []
    var appliedFilters: [String: Set<String>] = [:]
    
    var isLoadingWorkers = false
    var currentPage = 0
    var totalPages = 1
    private let pageSize = 10
    
    var isLoadingFactories = false
    var currentFactoryPage = 0
    var totalFactoryPages = 1
    private let factoryPageSize = 10
    
    var showAlert = false
    var alertMessage: String?
    
    private var debounceTask: Task<Void, Never>?
    let userRole: UserRole?
    
    var shouldShowFactoryFilter: Bool {
        userRole == .owner && factoryId == nil
    }
    
    init(factoryId: Int?, userRole: UserRole? = nil) {
        self.factoryId = factoryId
        self.userRole = userRole
    }
    
    func fetchAllWorkers(reset: Bool = false) async {
        guard !isLoadingWorkers else { return }
        isLoadingWorkers = true
        defer { isLoadingWorkers = false }
        
        if reset {
            workers = []
            currentPage = 0
        } else {
            guard currentPage < totalPages else { return }
        }
        
        do {
            let finalFactoryId: Int? = {
                if let id = factoryId { return id }

                if userRole == .owner {
                    if let selection = appliedFilters["Factory"], selection.count == 1,
                       let factoryName = selection.first,
                       let factory = factories.first(where: { $0.factoryName == factoryName }) {
                        return factory.id
                    }
                    return nil
                }

                if userRole == .plantHead || userRole == .chiefSupervisor {
                    return factoryId
                }

                return nil
            }()
            
            let statusParam: String? = {
                let statuses = (appliedFilters["Status"] ?? []).map { $0.lowercased() }
                return statuses.isEmpty ? nil : statuses.joined(separator: ",")
            }()
            
            let (sortByParam, sortDirectionParam) = mapSortToParams(selectedSort)
            
            let response = try await WorkerService.shared.fetchWorkers(
                page: currentPage,
                size: pageSize,
                sortBy: sortByParam,
                sortDirection: sortDirectionParam,
                status: statusParam,
                factoryId: finalFactoryId,
                search: searchText.trimmingCharacters(in: .whitespaces).isEmpty ? nil : searchText
            )
            
            totalPages = response.pagination.totalPages
            let newItems = response.data
            
            if reset {
                workers = newItems
                currentPage = 1
            } else {
                workers += newItems
                currentPage += 1
            }
        } catch {
            showAlert(with: "Cannot fetch workers: \(error.localizedDescription)")
        }
    }
    
    func loadNextPageIfNeeded(currentItem: Worker?) async {
        guard let currentItem, workers.last?.id == currentItem.id else { return }
        guard !isLoadingWorkers, currentPage < totalPages else { return }
        await fetchAllWorkers()
    }
    
    func applyFilters(_ filters: [String: Set<String>]) async {
        debounceTask?.cancel()
        appliedFilters = filters.filter { !$0.value.isEmpty }
        
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await fetchAllWorkers(reset: true)
        }
    }
    
    func applySort(_ sortOption: String?) async {
        selectedSort = sortOption
        await fetchAllWorkers(reset: true)
    }
    
    func updateSearchText(_ newText: String) {
        debounceTask?.cancel()
        searchText = newText
        
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await fetchAllWorkers(reset: true)
        }
    }
    
    func prepareDelete(workerId: Int) {
        workerIdToDelete = workerId
        showDeletePopUp = true
    }
    
    func cancelDelete() {
        workerIdToDelete = nil
        showDeletePopUp = false
    }
    
    func confirmDelete() async {
        guard let id = workerIdToDelete else { return }
        await deleteWorker(id: id)
        await fetchAllWorkers(reset: true)
        cancelDelete()
    }
    
    func deleteWorker(id: Int) async {
        workers.removeAll { $0.id == id }
        do {
            let response = try await WorkerService.shared.deleteWorker(workerID: id)
            showAlert(with: response.message)
        } catch {
            showAlert(with: "Could not delete worker: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        guard let sort = sort else { return (nil, nil) }
        switch sort {
        case "Sort by Name A-Z": return ("username", "asc")
        case "Sort by Name Z-A": return ("username", "desc")
        default: return (nil, nil)
        }
    }
    
    func refreshWithoutCancel() async {
        workers = []
        currentPage = 0
        totalPages = 1
        isLoadingWorkers = false
        await fetchAllWorkers(reset: true)
    }
    
    func getFactories(reset: Bool = false) async {
        guard !isLoadingFactories else { return }
        isLoadingFactories = true
        defer { isLoadingFactories = false }
        
        if reset {
            factories = []
            currentFactoryPage = 0
        } else {
            guard currentFactoryPage < totalFactoryPages else { return }
        }
        
        do {
            let response = try await FactoryService.shared.fetchFactories(
                page: currentFactoryPage,
                size: factoryPageSize,
                sortBy: nil,
                sortDirection: nil,
                search: nil,
                status: nil,
                location: nil
            )
            let newItems = response.data
            
            if reset {
                factories = newItems
                currentFactoryPage = 1
            } else {
                factories += newItems
                currentFactoryPage += 1
            }
        } catch {
            showAlert(with: "Could not get factories: \(error.localizedDescription)")
        }
    }
}
