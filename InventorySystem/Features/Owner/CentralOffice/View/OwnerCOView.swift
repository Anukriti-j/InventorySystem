import SwiftUI

struct OwnerCOView: View {
    @StateObject private var viewModel = OwnerCOViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Text("Central officer names")
                }
                .listStyle(.plain)
            }
            .navigationTitle("Central Officers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddSheet = true
                    } label: {
                        Text("Add +")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddCentralOfficerView()
        }   
    }
}


#Preview("Officers List") {
    OwnerCOView()
}
