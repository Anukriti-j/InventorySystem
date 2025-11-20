import SwiftUI

struct MerchandiseListView: View {
    @State private var viewModel = MerchandiseViewModel()
    let userRole: UserRole?
    
    init(userRole: UserRole?) {
        self.userRole = userRole
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FilterAndSortBar(viewModel: viewModel)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: viewModel.appliedFilters)
                
                MerchandiseList(viewModel: viewModel)
            }
            .navigationTitle("Merchandise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddSheet = true
                    } label: {
                        Label("Add", systemImage: "plus")
                            .fontWeight(.semibold)
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
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task { await viewModel.confirmDelete() }
                }
            } message: {
                Text("Are you sure you want to delete this merchandise?")
            }
            .alert(viewModel.alertMessage ?? "Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            }
            .task {
                await viewModel.fetchMerchandise(reset: true)
            }
        }
    }
}

struct MerchandiseList: View {
    @Bindable var viewModel: MerchandiseViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading && viewModel.merchandises.isEmpty {
                    ProgressView("Loading merchandise...")
                        .frame(maxWidth: .infinity, minHeight: 300)
                }
                else if viewModel.merchandises.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tshirt.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No Merchandise")
                            .font(.title2.bold())
                        Button("Retry") {
                            Task { await viewModel.fetchMerchandise(reset: true) }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity, minHeight: 500)
                }
                else {
                    ForEach(viewModel.merchandises) { item in
                        MerchandiseCardView(viewModel: viewModel, merchandise: item)
                            .task {
                                await viewModel.loadNextPageIfNeeded(currentItem: item)
                            }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView("Loading more items...")
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    else if viewModel.currentPage >= viewModel.totalPages {
                        Text("All items loaded")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            .padding(.vertical, 20)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .searchable(text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search merchandise...")
        .onChange(of: viewModel.searchText) { _, newValue in
            viewModel.updateSearchText(newValue)
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
}

struct FilterAndSortBar: View {
    @Bindable var viewModel: MerchandiseViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                FiltersBarView(
                    filters: [
                        "Status": ["Active", "Inactive"],
                        "StockStatus": ["In Stock", "Out of Stock"]
                    ],
                    selections: Binding(
                        get: { viewModel.appliedFilters },
                        set: { viewModel.appliedFilters = $0.filter { !$0.value.isEmpty } }
                    )
                )
                .onChange(of: viewModel.appliedFilters) { _, _ in
                    Task { await viewModel.applyFilters(viewModel.appliedFilters) }
                }
                
                Spacer(minLength: 20)
                
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
                            Task { await viewModel.applySort(newValue) }
                        }
                    )
                )
            }
            .padding(.horizontal)
        }
        .frame(height: 50)
        .padding(.top, 8)
        .background(Color(.systemBackground))
    }
}
