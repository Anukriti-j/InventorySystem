import SwiftUI
import Kingfisher

struct FactoryDetailView: View {
    @State private var factoryDetailViewModel = FactoryDetailViewModel()
    @State private var workerViewModel = FactoryWorkerDetailViewModel()
    @State private var toolViewModel = FactoryToolsDetailViewModel()
    @State private var productViewModel = FactoryProductsDetailViewModel()
    let factoryId: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            filterAndSortBar
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: factoryDetailViewModel.appliedFilters)
            
            Divider()
            
            Picker("", selection: $factoryDetailViewModel.selectedTab) {
                ForEach(FactoryDetailTab.allCases, id: \.self) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .onChange(of: factoryDetailViewModel.selectedTab) { oldValue, newValue in
                factoryDetailViewModel.appliedFilters = [:]
                factoryDetailViewModel.selectedSort = nil
            }
            
            switch factoryDetailViewModel.selectedTab {
            case .workers:
                List(workerViewModel.workers) { worker in
                    WorkerDetailCardView(worker: worker)
                }
                .listStyle(.plain)
                .searchable(
                    text: Binding(
                        get: { factoryDetailViewModel.searchText },
                        set: { newValue in
                            factoryDetailViewModel.updateSearchText(newValue) {
                                workerViewModel.updateSearch(newValue)
                            }
                        }
                    ),
                    prompt: "Search Workers"
                )

            case .tools:
                List(toolViewModel.tools) { tool in
                    ToolCardView(tool: tool)
                }
                .listStyle(.plain)
                .searchable(
                    text: Binding(
                        get: { factoryDetailViewModel.searchText },
                        set: { newValue in
                            factoryDetailViewModel.updateSearchText(newValue) {
                                toolViewModel.updateSearch(newValue)
                            }
                        }
                    ),
                    prompt: "Search Tools"
                )

            case .products:
                List(productViewModel.products) { product in
                    ProductCardView(product: product)
                }
                .listStyle(.plain)
                .searchable(
                    text: Binding(
                        get: { factoryDetailViewModel.searchText },
                        set: { newValue in
                            factoryDetailViewModel.updateSearchText(newValue) {
                                productViewModel.updateSearch(newValue)
                            }
                        }
                    ),
                    prompt: "Search Products"
                )

            }
        }
        .navigationTitle("Factory Details")
        .navigationBarTitleDisplayMode(.inline)
    
    }
}

extension FactoryDetailView {
    var currentFilters: [String: [String]] {
        switch factoryDetailViewModel.selectedTab {
        case .workers:
            return ["Status": ["Active", "Inactive"]]
        case .tools:
            return [
                "Category": ["Cat 1", "Cat 2", "Cat 3", "Cat 4", "Cat 5"],
                "Availability": ["In Stock", "Out of Stock"],
                "Cost": ["Expensive", "Inexpensive"]
            ]
        case .products:
            return [
                "Category": ["Cat 1", "Cat 2", "Cat 3", "Cat 4", "Cat 5"],
                "Availability": ["In Stock", "Out of Stock"]
            ]
        }
    }
    
    var currentSortOptions: [String] {
        switch factoryDetailViewModel.selectedTab {
        case .workers:
            return ["Alphabetically A-Z", "Alphabetically Z-A"]
        case .tools, .products:
            return [
                "Price High to Low",
                "Price Low to High",
                "Quantity High to Low",
                "Quantity Low to High"
            ]
        }
    }
    
    private var filterAndSortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                FiltersBarView(
                    filters: [
                        "Location": ["Pune", "Mumbai", "Delhi"],
                        "Status": ["Active", "Inactive"]
                    ],
                    selections: Binding(
                        get: { factoryDetailViewModel.appliedFilters },
                        set: { updated in
                            factoryDetailViewModel.appliedFilters = updated
                            Task { await factoryDetailViewModel.applyFilters(updated) }
                        }
                    )
                )
                
                Spacer()
                
                SortMenuView(
                    title: "Sort",
                    options: [
                        "Sort by Name A-Z",
                        "Sort by Name Z-A",
                        "Sort by City A-Z",
                        "Sort by City Z-A"
                    ],
                    selection: Binding(
                        get: { factoryDetailViewModel.selectedSort },
                        set: { newValue in
                            factoryDetailViewModel.selectedSort = newValue
                            Task { await factoryDetailViewModel.applySort(newValue) }
                        }
                    )
                )
            }
        }
        .frame(height: 40)
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        FactoryDetailView(factoryId: 1)
    }
}
