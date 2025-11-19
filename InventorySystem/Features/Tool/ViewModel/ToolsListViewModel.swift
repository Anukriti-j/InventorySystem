import Foundation
import SwiftUI

@MainActor
@Observable
final class ToolsListViewModel {
    var searchText = ""
    var showAddSheet = false
    var showEditSheet = false
    var showDeletePopUp = false
    var editingTool: Tool?
    private var toolIdToDelete: Int?
    
    var allTools: [Tool] = []
    var factories: [Factory] = []
    var categories: [ToolCategory] = []
    var appliedFilters: [String: Set<String>] = [:]
    var selectedSort: String?
    var shouldShowFactoryFilter: Bool {
        userRole == .owner && factoryId == nil
    }
    
    let factoryId: Int?
    let userRole: UserRole?
    
    var isLoading = false
    var currentPage = 0
    var totalPages = 1
    private let pageSize = 10
    
    var showAlert = false
    var alertMessage: String?
    
    private var searchDebounceTask: Task<Void, Never>?
    
    init(factoryId: Int?, userRole: UserRole?) {
        self.factoryId = factoryId
        self.userRole = userRole
    }
    
    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            if userRole == .owner {
                group.addTask { await self.getFactories() }
            }
            group.addTask { await self.getCategories() }
            group.addTask { await self.fetchTools(reset: true) }
        }
    }
    
    private func getFactories() async {
        do {
            let response = try await FactoryService.shared.fetchFactories(
                page: 0, size: 100, sortBy: nil, sortDirection: nil,
                search: nil, status: nil, location: nil
            )
            factories = response.data
        } catch {
            showAlert(message: "Failed to load factories")
        }
    }
    
    private func getCategories() async {
        do {
            let response = try await ToolService.shared.getCategories()
            categories = response.data
        } catch {
            showAlert(message: "Failed to load categories")
        }
    }
    
    func fetchTools(reset: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        if reset {
            allTools = []
            currentPage = 0
        }
        
        let effectiveFactoryId: Int? = {
            if userRole == .plantHead || userRole == .chiefSupervisor {
                return factoryId
            }
            if userRole == .owner {
                let names = appliedFilters["Factory"] ?? []
                if names.count == 1,
                   let name = names.first,
                   let factory = factories.first(where: { $0.factoryName == name }) {
                    return factory.id
                }
                return nil
            }
            return nil
        }()
        
        let categoryNames = appliedFilters["Category"]?.isEmpty == false
        ? Array(appliedFilters["Category"]!).joined(separator: ",")
        : nil
        
        let availability: String? = {
            let set = appliedFilters["Availability"] ?? []
            if set.contains("In Stock") && !set.contains("Out of Stock") { return "InStock" }
            if set.contains("Out of Stock") && !set.contains("In Stock") { return "OutOfStock" }
            return nil
        }()
        
        let (sortBy, sortDir) = mapSortToParams(selectedSort)
        
        let searchQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchParam = searchQuery.isEmpty ? nil : searchQuery
        
        do {
            let response = try await ToolService.shared.fetchTools(
                factoryId: effectiveFactoryId,
                categoryNames: categoryNames,
                availability: availability,
                page: currentPage,
                size: pageSize,
                sortBy: sortBy,
                sortDir: sortDir,
                search: searchParam
            )
            
            totalPages = response.pagination.totalPages
            let newTools = response.data
            
            if reset {
                allTools = newTools
                currentPage = 1
            } else {
                allTools += newTools
                currentPage += 1
            }
        } catch {
            showAlert(message: "Cannot fetch tools: \(error.localizedDescription)")
        }
    }
    
    func loadNextPageIfNeeded(currentItem: Tool) async {
        guard allTools.last?.id == currentItem.id,
              currentPage < totalPages,
              !isLoading else { return }
        await fetchTools()
    }
    
    func applyFilters(_ filters: [String: Set<String>]) async {
        appliedFilters = filters.filter { !$0.value.isEmpty }
        await fetchTools(reset: true)
    }
    
    func applySort(_ sort: String?) async {
        selectedSort = sort
        await fetchTools(reset: true)
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
        searchDebounceTask?.cancel()
        searchDebounceTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await self.fetchTools(reset: true)
        }
    }
    
    private func mapSortToParams(_ sort: String?) -> (String?, String?) {
        guard let sort = sort else { return (nil, nil) }
        switch sort {
        case "Name A to Z":                     return ("name", "asc")
        case "Name Z to A":                     return ("name", "desc")
        case "Available Quantity High to Low":  return ("availableQuantity", "desc")
        case "Available Quantity Low to High":  return ("availableQuantity", "asc")
        default:                                return (nil, nil)
        }
    }
    
    func prepareDelete(toolId: Int) {
        toolIdToDelete = toolId
        showDeletePopUp = true
    }
    
    func cancelDelete() {
        showDeletePopUp = false
        toolIdToDelete = nil
    }
    
    func confirmDelete() async {
        guard let id = toolIdToDelete else { return }
        allTools.removeAll { $0.id == id }
        do {
            let resp = try await ToolService.shared.deleteTool(toolID: id)
            showAlert(message: resp.message)
        } catch {
            showAlert(message: "Failed to delete tool")
        }
        cancelDelete()
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
