import Foundation

@MainActor
@Observable
final class CentralOfficerViewModel {
    var showAlert = false
    var alertMessage: String?
    var showAddSheet = false
    var centralOfficers: [CentralOfficer] = []
    var currentPage = 0
    var totalPages = 1
    var isLoading = false
    var searchText = ""
    var selectedSort: String?
    var showDeletePopUp = false
    var centralOfficerToDelete: Int?
    
    private let pageSize = 10
    var appliedFilters: [String: Set<String>] = [:]
    private var debounceTask: Task<Void, Never>?

    func fetchCentralOfficer(reset: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        if reset {
            centralOfficers = []
            currentPage = 0
        }

        let statusParam: String? = {
            let statuses = appliedFilters["Status"] ?? []
            return statuses.isEmpty ? nil : statuses.map { $0.lowercased() == "active" ? "ACTIVE" : "INACTIVE" }.joined(separator: ",")
        }()

        let (sortByParam, sortDirectionParam) = mapSortToParams(selectedSort)
        let searchParam = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : searchText

        do {
            let response = try await CentralOfficeService.shared.fetchCentralOfficer(
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
            if !Task.isCancelled {
                showAlert(with: "Cannot fetch officers: \(error.localizedDescription)")
            }
        }
    }

    func loadNextPageIfNeeded(currentItem: CentralOfficer?) async {
        guard let currentItem, centralOfficers.last?.id == currentItem.id else { return }
        guard currentPage < totalPages, !isLoading else { return }
        await fetchCentralOfficer()
    }

    func applyFilters(_ filters: [String: Set<String>]) async {
        appliedFilters = filters.filter { !$0.value.isEmpty }
        await fetchCentralOfficer(reset: true)
    }

    func applySort(_ sortOption: String?) async {
        selectedSort = sortOption
        await fetchCentralOfficer(reset: true)
    }

    func updateSearchText(_ newText: String) {
        searchText = newText
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await self.fetchCentralOfficer(reset: true)
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

    func prepareDelete(centralOfficerID: Int) {
        centralOfficerToDelete = centralOfficerID
        showDeletePopUp = true
    }

    func cancelDelete() {
        showDeletePopUp = false
        centralOfficerToDelete = nil
    }

    func confirmDelete() async {
        guard let id = centralOfficerToDelete else { return }
        centralOfficers.removeAll { $0.id == id }
        do {
            let response = try await CentralOfficeService.shared.deleteCentralOfficer(id: id)
            showAlert(with: response.message)
        } catch {
            showAlert(with: "Failed to delete officer")
        }
        cancelDelete()
    }

    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
