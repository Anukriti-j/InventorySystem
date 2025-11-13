import Foundation
import SwiftUI

@MainActor
@Observable
final class OwnerWorkerViewModel {
    // MARK: - UI State
    var searchText: String = ""
    var showfilterSheet: Bool = false
    var showSortSheet: Bool = false
    var selectedSort: String? = nil
    var showWorkerDetail: Bool = false
    var showDeletePopUp: Bool = false
    var workerIdToDelete: Int? = nil

    // MARK: - Data
    var workers: [Worker] = []
    var factories: [Factory] = []
    var appliedFilters: [String: Set<String>] = [:]

    // MARK: - Pagination
    var isLoadingWorkers = false
    var currentPage = 0
    var totalPages = 1
    private let pageSize = 10
    
    var isLoadingFactories = false
    var currentFactoryPage = 0
    var totalFactoryPages = 1
    private let factoryPageSize = 10

    // MARK: - Alerts
    var showAlert = false
    var alertMessage: String?

    private var debounceTask: Task<Void, Never>? = nil

    func fetchWorkers(reset: Bool = false) async {
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
            //TODO: Replace with factoryName
            let locationParam: String? = {
                let locs = (appliedFilters["Location"] ?? [])
                    .map { $0.capitalized }
                return locs.isEmpty ? nil : locs.joined(separator: ",")
            }()

            let statusParam: String? = {
                let statuses = (appliedFilters["Status"] ?? [])
                    .map { $0.lowercased() }
                return statuses.isEmpty ? nil : statuses.joined(separator: ",")
            }()

            let (sortByParam, sortDirectionParam) = mapSortToParams(selectedSort)
           // let searchParam = searchText.trimmingCharacters(in: .whitespaces).isEmpty ? nil : searchText

            let response = try await OwnerWorkerService.shared.fetchWorkers(
                page: currentPage,
                size: pageSize,
                sortBy: sortByParam,
                sortDirection: sortDirectionParam,
                status: statusParam
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
        guard let currentItem = currentItem else { return }
        guard workers.last?.id == currentItem.id else { return }
        guard !isLoadingWorkers, currentPage < totalPages else { return }
        await fetchWorkers()
    }

    func applyFilters(_ filters: [String: Set<String>]) async {
        debounceTask?.cancel()
        appliedFilters = filters.filter { !$0.value.isEmpty }

        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300 * 1_000_000)
            guard !Task.isCancelled else { return }
            await self?.fetchWorkers(reset: true)
        }
    }

    func applySort(_ sortOption: String?) async {
        selectedSort = sortOption
        await fetchWorkers(reset: true)
    }

    func updateSearchText(_ newText: String) {
        debounceTask?.cancel()
        searchText = newText

        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300 * 1_000_000)
            guard !Task.isCancelled else { return }
            await self?.fetchWorkers(reset: true)
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
        cancelDelete()
    }

    func deleteWorker(id: Int) async {
        workers.removeAll { $0.id == id }
        do {
            let response = try await OwnerWorkerService.shared.deleteWorker(workerID: id)
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

        await fetchWorkers(reset: true)
    }
    
    func getFactories(reset: Bool = false) async {
        guard !isLoadingFactories else { return }
        isLoadingFactories = true
        defer {
            isLoadingFactories = false
        }
        
        if reset {
            factories = []
            currentFactoryPage = 0
        } else {
            guard currentFactoryPage < totalFactoryPages else { return }
        }
        
        do {
            let response = try await OwnerFactoryService.shared.fetchFactories(
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
