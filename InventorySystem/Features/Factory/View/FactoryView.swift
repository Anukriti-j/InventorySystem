import SwiftUI

struct FactoryView: View {
    @State private var viewModel = FactoryViewModel()
    
    var body: some View {
        VStack {
            filterAndSortBar
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: viewModel.appliedFilters)
            factoryList
                .animation(.easeInOut, value: viewModel.searchText)
            
        }
        .navigationTitle("Factories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showAddSheet = true
                } label: {
                    Text("Add +")
                        .fontWeight(.bold)
                }
            }
        }
        .task { await loadInitialData() }
        
        .alert("Alert", isPresented: $viewModel.showDeletePopUp) {
            Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
            Button("Delete", role: .destructive) {
                Task { await viewModel.confirmDelete() }
            }
        } message: {
            Text("Are you sure you want to delete the selection!")
        }
        .navigationDestination(isPresented: $viewModel.showFactoryDetail) {
            FactoryDetailView(factoryId: viewModel.selectedFactory?.id ?? -1)
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddFactoryView(ownerFactoryViewModel: viewModel)
        }
        .sheet(item: $viewModel.selectedFactory) { factory in
            EditFactoryView(factory: factory, factoryViewModel: viewModel)
        }
    }
}

extension FactoryView {
    
    private var filterAndSortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                FiltersBarView(
                    filters: [
                        "Location": ["Pune", "Mumbai", "Delhi"],
                        "Status": ["Active", "Inactive"]
                    ],
                    selections: Binding(
                        get: { viewModel.appliedFilters },
                        set: { updated in
                            viewModel.appliedFilters = updated
                            Task { await viewModel.applyFilters(updated) }
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
                        get: { viewModel.selectedSort },
                        set: { newValue in
                            viewModel.selectedSort = newValue
                            Task { await viewModel.applySort(newValue) }
                        }
                    )
                )
            }
        }
        .frame(height: 40)
        .padding(.top, 8)
    }
    
    private var factoryList: some View {
        ZStack {
            if viewModel.isLoading && viewModel.factories.isEmpty {
                ProgressView("Loading factories...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                    .animation(.easeIn, value: viewModel.isLoading)
            } else if viewModel.factories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No factories found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Try adjusting your filters or search criteria.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity.combined(with: .scale))
                .animation(.spring(), value: viewModel.factories.isEmpty)
            } else {
                List {
                    ForEach(viewModel.factories) { factory in
                        Button {
                           
                            viewModel.showFactoryDetail = true
                        } label: {
                            FactoryInfoCardView(
                                viewModel: viewModel,
                                factory: factory
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .task {
                            await viewModel.loadNextPageIfNeeded(currentItem: factory)
                        }
                    }
                    
                    if viewModel.isLoading && !viewModel.factories.isEmpty && viewModel.currentPage < viewModel.totalPages {
                        ProgressView("Loading more…")
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                            .transition(.opacity)
                            .animation(.easeIn, value: viewModel.isLoading)
                    } else if !viewModel.isLoading && !viewModel.factories.isEmpty && viewModel.currentPage >= viewModel.totalPages {
                        Text("All factories loaded")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                }
                .animation(.easeInOut, value: viewModel.factories)
                .listStyle(.plain)
                .refreshable {
                    Task {
                        await viewModel.fetchFactories(reset: true)
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText)
    }
    
    private func loadInitialData() async {
        await viewModel.fetchFactories(reset: true)
    }
}

struct FactoryInfoRow: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}
