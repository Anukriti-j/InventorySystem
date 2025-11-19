import Foundation
import Observation

enum FactoryDetailTab: CaseIterable {
    case workers, tools
    
    var title: String {
        switch self {
        case .workers: return "Workers"
        case .tools: return "Tools"
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
    
    func applyFilters(_ filters: [String: Set<String>]) async {
        debounceTask?.cancel()
        appliedFilters = filters
        
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
    }
    
    func applySort(_ sort: String?) async {
        debounceTask?.cancel()
        selectedSort = sort
        
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
    }
    
    func updateSearchText(_ newValue: String) {
        debounceTask?.cancel()
        searchText = newValue
        
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
    }
}
