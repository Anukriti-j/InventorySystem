import SwiftUI

struct MerchandiseListView: View {
    @State private var viewModel = MerchandiseViewModel()
    let userRole: UserRole?
    
    init(userRole: UserRole?) {
        self.userRole = userRole
    }
    
    var body: some View {
            VStack(spacing: 0) {
                
                FilterAndSortBar(viewModel: viewModel)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: viewModel.appliedFilters)
                
                MerchandiseList(viewModel: viewModel)
            }
            
            .navigationTitle("Merchandise")
            .navigationBarTitleDisplayMode(.inline)
            
            .searchable(text: searchBinding)
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddSheet = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            
            .refreshable {
                await viewModel.fetchMerchandise(reset: true)
            }
            
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddMerchandiseView()
            }
            
            .alert("Delete Merchandise", isPresented: $viewModel.showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task { await viewModel.confirmDelete() }
                }
            } message: {
                Text("Are you sure you want to delete this merchandise?")
            }
            
            .alert(viewModel.alertMessage ?? "", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear {
                Task {
                    await viewModel.fetchMerchandise(reset: true)
                }
            }
        
    }
    
    private var searchBinding: Binding<String> {
        Binding(
            get: { viewModel.searchText },
            set: { newValue in
                viewModel.updateSearchText(newValue)
            }
        )
    }
    
}

struct MerchandiseList: View {
    @Bindable var viewModel: MerchandiseViewModel
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading && !viewModel.merchandises.isEmpty {
                ProgressView("Loading more…")
                    .padding()
            } else if viewModel.merchandises.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.merchandises) { item in
                        MerchandiseCardView(viewModel: viewModel, merchandise: item)
                            .task {
                                await viewModel.loadNextPageIfNeeded(currentItem: item)
                            }
                    }
                    
                    
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("No Merchandise")
                .font(.headline)
                .foregroundColor(.secondary)
            Button("Retry") {
                Task { await viewModel.fetchMerchandise(reset: true) }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

}

struct FilterAndSortBar: View {
    @Bindable var viewModel: MerchandiseViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                
                FiltersBarView(
                    filters: [
                        "Status": ["Inactive", "Active"],
                        "StockStatus": ["In Stock", "Out of Stock"]
                    ],
                    selections: Binding(
                        get: { viewModel.appliedFilters },
                        set: { updated in
                            viewModel.appliedFilters = updated
                            viewModel.applyFilters(updated)
                        }
                    )
                )
                
                SortMenuView(
                    title: "Sort",
                    options: [
                        "Reward Points High to Low",
                        "Reward Points Low to High"
                    ],
                    selection: Binding(
                        get: { viewModel.selectedSort },
                        set: { newValue in
                            viewModel.selectedSort = newValue
                            viewModel.applySort(newValue)
                        }
                    )
                )
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 40)
        .padding(.vertical, 6)
    }
}

