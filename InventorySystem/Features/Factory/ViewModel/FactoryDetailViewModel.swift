import Foundation

enum FactoryDetailTab: CaseIterable {
    case workers, tools, products
    
    var title: String {
        switch self {
        case .workers: return "Workers"
        case .tools: return "Tools"
        case .products: return "Products"
        }
    }
}

@Observable
final class FactoryDetailViewModel {
    
    // UI State
    var appliedFilters: [String: Set<String>] = [:]
    var selectedSort: String? = nil
    var selectedTab: FactoryDetailTab = .workers
    var searchText: String = ""
    
    private var debounceTask: Task<Void, Never>? = nil
    
    // Filter + Sort apply handlers
    func applyFilters(_ filters: [String: Set<String>]) async {
        debounceTask?.cancel()
        appliedFilters = filters
        
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
    }
    
    func applySort(_ sort: String?) async {
        selectedSort = sort
        debounceTask?.cancel()
        
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
    }
    
    func updateSearchText(_ newValue: String, callback: @escaping () -> Void) {
        debounceTask?.cancel()
        searchText = newValue
        
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            callback()   // child VM search trigger
        }
    }
}

