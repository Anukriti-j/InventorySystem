import SwiftUI

struct OwnerFactoryDetailView: View {
    
    @State private var selectedTab: FactoryDetailTab = .workers
    @State private var searchText: String = ""
    @State private var showFilterSheet: Bool = false
    @State private var showSortSheet: Bool = false
    
    // MARK: Mock Data
    let workers = ["Rohit Singh", "Neha Patel", "David White", "Aman Gupta"]
    let tools = ["Wrench", "Drill Machine", "Lathe Tool", "Hammer"]
    let products = ["Engine Parts", "Steel Rods", "Hydraulic Pumps", "Gearbox"]
    
    // MARK: Filtered List Based on Search & Tab
    var filteredList: [String] {
        switch selectedTab {
        case .workers:
            return workers.filter { searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText) }
        case .tools:
            return tools.filter { searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText) }
        case .products:
            return products.filter { searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            FilterSortBar(showFilterSheet: $showFilterSheet, showSortSheet: $showSortSheet)
            
            Divider()
            
            // MARK: Tab Picker
            Picker("", selection: $selectedTab) {
                
                ForEach(FactoryDetailTab.allCases, id: \.self) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // MARK: List for Selected Tab
            List(filteredList, id: \.self) { item in
                Text(item)
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search \(selectedTab.title)")
        }
        .navigationTitle("Factory Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFilterSheet) {
            if selectedTab == .workers {
                FilterListSheetView(filters: [
                    "Status" : ["Active", "Inactive"]
                ]
                )
            } else if selectedTab == .tools {
                FilterListSheetView(filters: [
                    "Category" : ["Cat 1", "Cat 2", "Cat 3", "Cat 4", "Cat 5"],
                    "Availability": ["In Stock", "Out of Stock"],
                    "Cost": ["Expensive", "Inexpensive"]
                ])
            } else if selectedTab == .products {
                FilterListSheetView(filters: [
                    "Category" : ["Cat 1", "Cat 2", "Cat 3", "Cat 4", "Cat 5"],
                    "Availability": ["In Stock", "Out of Stock"]
                ])
            }
        }
        .sheet(isPresented: $showSortSheet) {
            if selectedTab == .workers {
                SortListSheetView(sortOptions: [
                    "Alphabetically A-Z"
                ])
            } else if selectedTab == .tools || selectedTab == .products {
                SortListSheetView(sortOptions: [
                    "Price High to Low",
                    "Price Low to High",
                    "Quantity High to Low",
                    "Quantity Low to High"
                ])
            }
            
        }
    }
}

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

#Preview {
    NavigationStack {
        OwnerFactoryDetailView()
    }
}
