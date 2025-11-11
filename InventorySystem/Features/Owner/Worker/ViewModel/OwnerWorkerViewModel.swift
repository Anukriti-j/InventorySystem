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

    // MARK: - Fetch Workers
    func fetchWorkers(reset: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        if reset {
            workers = []
            currentPage = 0
        } else {
            guard currentPage < totalPages else { return }
        }

        do {
            let locationParam: String? = {
                let locs = (appliedFilters["Location"] ?? [])
                    .map { $0.capitalized }
                return locs.isEmpty ? nil : locs.joined(separator: ",")
            }()

            let statusParam: String? = {
                let statuses = (appliedFilters["Status"] ?? [])
                    .map { $0.uppercased() }
                return statuses.isEmpty ? nil : statuses.joined(separator: ",")
            }()

            let (sortByParam, sortDirectionParam) = mapSortToParams(selectedSort)
           // let searchParam = searchText.trimmingCharacters(in: .whitespaces).isEmpty ? nil : searchText

            let response = try await OwnerWorkerService.shared.fetchWorkers(
                page: currentPage,
                size: pageSize,
                sortBy: sortByParam,
                sortDirection: sortDirectionParam,
                status: statusParam,
                location: locationParam
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

    // MARK: - Pagination
    func loadNextPageIfNeeded(currentItem: Worker?) async {
        guard let currentItem = currentItem else { return }
        guard workers.last?.id == currentItem.id else { return }
        guard !isLoading, currentPage < totalPages else { return }
        await fetchWorkers()
    }

    // MARK: - Filters
    func applyFilters(_ filters: [String: Set<String>]) async {
        debounceTask?.cancel()
        appliedFilters = filters.filter { !$0.value.isEmpty }

        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300 * 1_000_000)
            guard !Task.isCancelled else { return }
            await self?.fetchWorkers(reset: true)
        }
    }

    // MARK: - Sort
    func applySort(_ sortOption: String?) async {
        selectedSort = sortOption
        await fetchWorkers(reset: true)
    }

    // MARK: - Search
    func updateSearchText(_ newText: String) {
        debounceTask?.cancel()
        searchText = newText

        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300 * 1_000_000)
            guard !Task.isCancelled else { return }
            await self?.fetchWorkers(reset: true)
        }
    }
//
//    // MARK: - Delete
//    func prepareDelete(workerId: Int) {
//        workerIdToDelete = workerId
//        showDeletePopUp = true
//    }
//
//    func cancelDelete() {
//        workerIdToDelete = nil
//        showDeletePopUp = false
//    }
//
//    func confirmDelete() async {
//        guard let id = workerIdToDelete else { return }
//        await deleteWorker(id: id)
//        cancelDelete()
//    }

//    func deleteWorker(id: Int) async {
//        workers.removeAll { $0.workerID == id }
//        do {
//            let response = try await OwnerWorkerService.shared.deleteWorker(workerID: id)
//            showAlert(with: response.message)
//        } catch {
//            showAlert(with: "Could not delete worker: \(error.localizedDescription)")
//        }
//    }

    // MARK: - Helpers
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }

    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        guard let sort = sort else { return (nil, nil) }
        switch sort {
        case "Sort by Name A-Z": return ("name", "asc")
        case "Sort by Name Z-A": return ("name", "desc")
        case "Sort by City A-Z": return ("city", "asc")
        case "Sort by City Z-A": return ("city", "desc")
        case "Sort by Role A-Z": return ("role", "asc")
        case "Sort by Role Z-A": return ("role", "desc")
        default: return (nil, nil)
        }
    }
}
