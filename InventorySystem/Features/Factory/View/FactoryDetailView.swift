import SwiftUI
import Kingfisher

struct FactoryDetailView: View {
    @State private var viewModel = FactoryDetailViewModel()
    @Environment(SessionManager.self) var manager
    let factoryId: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Picker("", selection: $viewModel.selectedTab) {
                ForEach(FactoryDetailTab.allCases, id: \.self) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .onChange(of: viewModel.selectedTab) { _, _ in
                viewModel.appliedFilters = [:]
                viewModel.selectedSort = nil
                viewModel.searchText = ""
            }
            
            Divider()
            
            switch viewModel.selectedTab {
                
            case .workers:
                WorkerListView(
                    factoryId: factoryId,
                    userRole: manager.user?.userRole
                )
                
            case .tools:
                ToolsListView(
                    factoryId: factoryId,
                    userRole: manager.user?.userRole
                )
            }
        }
        .navigationTitle("Factory Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
