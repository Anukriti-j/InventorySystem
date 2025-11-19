import SwiftUI

struct ChiefSupervisorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewmodel: ChiefSupervisorViewModel
    @Environment(FactorySessionManager.self) var factorySessionManager
    
    init(factoryId: Int) {
        _viewmodel = State(wrappedValue: ChiefSupervisorViewModel(selectedFactoryId: factoryId))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Section {
                if let supervisors = viewmodel.supervisors, !supervisors.isEmpty {
                    ForEach(supervisors) { supervisor in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Chief Supervisor")
                                .font(.headline)

                            HStack {
                                Text("Name:").foregroundStyle(.secondaryText)
                                Text(supervisor.name)
                            }
                            HStack {
                                Text("Email:").foregroundStyle(.secondaryText)
                                Text(supervisor.email)
                            }
                            HStack {
                                Text("Active:").foregroundStyle(.secondaryText)
                                Text(supervisor.isActive)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Button("Add Chief Supervisor") {
                        viewmodel.showAddSupervisorSheet = true
                    }
                    .customStyle()
                }

            }
        }
        .navigationTitle("Chief Supervisor")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewmodel.getSupervisor()
            }
        }
        .sheet(isPresented: $viewmodel.showAddSupervisorSheet) {
            AddSupervisorView(parentViewModel: viewmodel)
        }
        .alert(viewmodel.alertMessage, isPresented: $viewmodel.showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}
