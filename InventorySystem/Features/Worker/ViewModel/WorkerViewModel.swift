import Foundation
import SwiftUI

@MainActor
@Observable
final class WorkerViewModel {
    var searchText: String = ""
    var selectedSort: String? = nil
    var showWorkerDetail: Bool = false
    var showDeletePopUp: Bool = false
    var workerIdToDelete: Int? = nil
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
    
    private var debounceTask: Task<Void, Never>? = nil
    let userRole: UserRole?
    
    init(factoryId: Int?, userRole: UserRole? = nil) {
        self.factoryId = factoryId
        self.userRole = userRole
    }
    
    // FIXED: Only one factory filter at a time
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
                // PlantHead & ChiefSupervisor → always use their factory
                if userRole == .plantHead || userRole == .chiefSupervisor {
                    return factoryId
                }
                
                // Owner → only if EXACTLY ONE factory selected
                if userRole == .owner {
                    let names = appliedFilters["Factory"] ?? []
                    if names.count == 1,
                       let name = names.first,
                       let factory = factories.first(where: { $0.factoryName == name }) {
                        return factory.id
                    }
                    return nil  // 0 or 2+ → show all
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
                factoryId: finalFactoryId,  // ← Single Int? → no crash
                search: searchText.trimmingCharacters(in: .whitespaces).isEmpty ? nil : searchText.trimmingCharacters(in: .whitespaces)
            )
            
            totalPages = response.pagination.totalPages
            let newItems = response.data ?? []
            
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
        guard let currentItem = currentItem else { return }
        guard workers.last?.id == currentItem.id else { return }
        guard !isLoadingWorkers, currentPage < totalPages else { return }
        await fetchAllWorkers()
    }
    
    func applyFilters(_ filters: [String: Set<String>]) async {
        debounceTask?.cancel()
        appliedFilters = filters.filter { !$0.value.isEmpty }
        
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await self?.fetchAllWorkers(reset: true)
        }
    }
    
    func applySort(_ sortOption: String?) async {
        selectedSort = sortOption
        await fetchAllWorkers(reset: true)
    }
    
    func updateSearchText(_ newText: String) {
        debounceTask?.cancel()
        searchText = newText
        
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await self?.fetchAllWorkers(reset: true)
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
