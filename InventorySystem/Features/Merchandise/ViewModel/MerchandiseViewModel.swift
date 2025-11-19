import Foundation

@MainActor
@Observable
class MerchandiseViewModel {

    var merchandises: [Merchandise] = []

    var showAddSheet = false
    var showEditSheet = false
    var selectedMerchandise: Merchandise?
    var showDeleteAlert = false
    var merchandiseToDelete: Merchandise?

    var alertMessage: String?
    var showAlert = false

    // MARK: - Search / Filter / Sort
    var searchText = ""
    var appliedFilters: [String: Set<String>] = [:]
    var selectedSort: String? = nil
    private var debounceTask: Task<Void, Never>? = nil

    // MARK: - Pagination
    private let pageSize = 10
    var currentPage = 0
    var totalPages = 1
    var isLoading = false

    private static var lastFetchTime = Date.distantPast

    // MARK: - Fetch merchandise
    func fetchMerchandise(reset: Bool = false) async {
        guard !isLoading else { return }

        // Prevent double rapid calls
        let now = Date()
        if now.timeIntervalSince(Self.lastFetchTime) < 0.3 { return }
        Self.lastFetchTime = now

        isLoading = true
        defer { isLoading = false }

        if reset {
            merchandises = []
            currentPage = 0
        } else if currentPage >= totalPages {
            return
        }

        do {
            let status = appliedFilters["Status"]?
                .map { $0.uppercased() }
                .joined(separator: ",")
            
            let stockStatus: String? = {
                let set = appliedFilters["StockStatus"] ?? []
                if set.contains("In Stock") && !set.contains("Out of Stock") { return "InStock" }
                if set.contains("Out of Stock") && !set.contains("In Stock") { return "OutOfStock" }
                return nil
            }()

            let (sortBy, sortDirection) = mapSortToParams(selectedSort)
            let search = searchText.trimmingCharacters(in: .whitespaces).isEmpty ? nil : searchText

            let response = try await MerchandiseService.shared.fetchMerchandise(
                page: currentPage,
                size: pageSize,
                sortBy: sortBy,
                sortDirection: sortDirection,
                search: search,
                status: status,
                stockStatus: stockStatus
            )

            totalPages = response.pagination.totalPages

            if reset {
                merchandises = response.data
                currentPage = 1
            } else {
                merchandises.append(contentsOf: response.data)
                currentPage += 1
            }

        } catch {
            showAlert(message: "Failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Debounce
    func updateSearchText(_ text: String) {
        searchText = text
        applyDebouncedReload()
    }

    func applyFilters(_ filters: [String: Set<String>]) {
        appliedFilters = filters.filter { !$0.value.isEmpty }
        applyDebouncedReload()
    }

    func applySort(_ sort: String?) {
        selectedSort = sort
        Task { await fetchMerchandise(reset: true) }
    }

    private func applyDebouncedReload() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            await fetchMerchandise(reset: true)
        }
    }

    func loadNextPageIfNeeded(currentItem: Merchandise) async {
        guard merchandises.last?.id == currentItem.id else { return }
        guard !isLoading else { return }
        await fetchMerchandise()
    }
    
    func requestDelete(_ item: Merchandise) {
        merchandiseToDelete = item
        showDeleteAlert = true
    }

    func confirmDelete() async {
        guard let item = merchandiseToDelete else { return }
        await deleteMerchandise(id: item.id)
    }

    func deleteMerchandise(id: Int) async {
        merchandises.removeAll { $0.id == id }
        do {
            let resp = try await MerchandiseService.shared.deleteMerchandise(merchandiseId: id)
            showAlert(message: resp.message)
        } catch {
            showAlert(message: error.localizedDescription)
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }

    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        switch sort {
//        case "Sort by Name A-Z": return ("name", "asc")
//        case "Sort by Name Z-A": return ("name", "desc")
        case "Points High to Low": return ("requiredpoints", "desc")
        case "Points Low to High": return ("requiredpoints", "asc")
        default: return (nil, nil)
        }
    }
}
