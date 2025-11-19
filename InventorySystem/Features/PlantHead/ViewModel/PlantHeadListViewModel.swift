import SwiftUI

@Observable
final class PlantHeadListViewModel {
    var searchText = ""
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
    var selectedSort: String?
    private var debounceTask: Task<Void, Never>?

    func fetchPlantHeads(reset: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        if reset {
            plantHeads = []
            currentPage = 0
        }

        let statusParam: String? = {
            let statuses = appliedFilters["Status"] ?? []
            return statuses.isEmpty ? nil : statuses.map { $0.lowercased() == "active" ? "ACTIVE" : "INACTIVE" }.joined(separator: ",")
        }()

        let (sortByParam, sortDirectionParam) = mapSortToParams(selectedSort)
        let searchParam = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : searchText

        do {
            let response = try await PlantHeadService.shared.fetchPlantHeads(
                page: currentPage,
                size: pageSize,
                role: "planthead",
                sortBy: sortByParam,
                sortDirection: sortDirectionParam,
                name: searchParam,
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

    func loadNextPageIfNeeded(currentItem: PlantHead?) async {
        guard let currentItem, plantHeads.last?.id == currentItem.id else { return }
        guard currentPage < totalPages, !isLoading else { return }
        await fetchPlantHeads()
    }

    func applyFilters(_ filters: [String: Set<String>]) async {
        appliedFilters = filters.filter { !$0.value.isEmpty }
        await fetchPlantHeads(reset: true)
    }

    func applySort(_ sortOption: String?) async {
        selectedSort = sortOption
        await fetchPlantHeads(reset: true)
    }

    func updateSearchText(_ newText: String) {
        searchText = newText
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await self.fetchPlantHeads(reset: true)
        }
    }

    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        guard let sort = sort else { return (nil, nil) }
        switch sort {
        case "Sort by Name A-Z": return ("username", "asc")
        case "Sort by Name Z-A": return ("username", "desc")
        default: return (nil, nil)
        }
    }

    func prepareDelete(plantheadId: Int) {
        plantheadToDelete = plantheadId
        showDeletePopUp = true
    }

    func cancelDelete() {
        showDeletePopUp = false
        plantheadToDelete = nil
    }

    func confirmDelete() async {
        guard let id = plantheadToDelete else { return }
        plantHeads.removeAll { $0.id == id }
        do {
            let response = try await CentralOfficeService.shared.deleteCentralOfficer(id: id)
            showAlert(with: response.message)
        } catch {
            showAlert(with: "Failed to delete PlantHead")
        }
        cancelDelete()
    }

    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
