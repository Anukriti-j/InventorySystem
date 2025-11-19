import SwiftUI

struct FactoryView: View {
    @State private var viewModel = FactoryViewModel()

    var body: some View {
        VStack {
            filterAndSortBar
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: viewModel.appliedFilters)

            factoryList
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
        .task {
            await viewModel.fetchFactories(reset: true)
        }
        .alert("Delete Factory", isPresented: $viewModel.showDeletePopUp) {
            Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
            Button("Delete", role: .destructive) {
                Task { await viewModel.confirmDelete() }
            }
        } message: {
            Text("Are you sure you want to delete this factory?")
        }
        .navigationDestination(isPresented: $viewModel.showFactoryDetail) {
            if let factory = viewModel.selectedFactory {
                FactoryDetailView(factoryId: factory.id)
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddFactoryView(ownerFactoryViewModel: viewModel)
        }
        .sheet(item: $viewModel.factoryToEdit) { factory in
            EditFactoryView(factory: factory, factoryViewModel: viewModel)
        }
    }
}

extension FactoryView {
    private var filterAndSortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                FiltersBarView(
                    filters: [
                        "Location": ["Pune", "Mumbai", "Delhi", "Bangalore", "Chennai"],
                        "Status": ["Active", "Inactive"]
                    ],
                    selections: Binding(
                        get: { viewModel.appliedFilters },
                        set: { viewModel.appliedFilters = $0.filter { !$0.value.isEmpty } }
                    )
                )
                .onChange(of: viewModel.appliedFilters) { _ in
                    Task { await viewModel.applyFilters(viewModel.appliedFilters) }
                }

                Spacer(minLength: 20)

                SortMenuView(
                    title: "Sort",
                    options: [
                        "Sort by Name A-Z", "Sort by Name Z-A",
                        "Sort by City A-Z", "Sort by City Z-A"
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
    }

    private var factoryList: some View {
        ZStack {
            if viewModel.isLoading && viewModel.factories.isEmpty {
                ProgressView("Loading factories...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if viewModel.factories.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "building.2.crop.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No factories found")
                        .font(.title3.bold())
                    Text("Try adjusting filters or add a new factory")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                List {
                    ForEach(viewModel.factories) { factory in
                        FactoryInfoCardView(
                            viewModel: viewModel,
                            factory: factory,
                            onCardTap: {
                                viewModel.selectedFactory = factory
                                viewModel.showFactoryDetail = true
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .task {
                            await viewModel.loadNextPageIfNeeded(currentItem: factory)
                        }
                    }

                    if viewModel.isLoading && viewModel.currentPage < viewModel.totalPages {
                        ProgressView("Loading more...")
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                    else if viewModel.currentPage >= viewModel.totalPages {
                        Text("All factories loaded")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.fetchFactories(reset: true)
                }
            }
        }
        .searchable(text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search factories...")
        .onChange(of: viewModel.searchText) { _, newValue in
            viewModel.updateSearchText(newValue)
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
}
