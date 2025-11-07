import SwiftUI

struct PHPersonnelView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewmodel = PHPersonnelViewModel()
    
    var body: some View {
        NavigationStack {
            if let supervisor = viewmodel.supervisor {
                VStack {
                    Text("Chief Supervisor")
                        .font(.system(size: 20, weight: .bold))
                    HStack {
                        Text("Name:")
                            .foregroundStyle(.secondaryText)
                        Text(supervisor.name)
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("Email")
                            .foregroundStyle(.secondaryText)
                        Text(supervisor.email)
                            .fontWeight(.bold)
                    }
                    HStack {
                        Text("Active")
                            .foregroundStyle(.secondaryText)
                        Text(supervisor.isActive)
                            .fontWeight(.bold)
                    }  
                }
            } else {
                Button("Add chief supervisor") {
                    viewmodel.showAddSupervisorSheet = true
                }
            }
            
            Button("Add workers") {
                // add worker
            }
            
            List {
                ForEach(viewmodel.workers, id: \.self) { worker in
                    Text(worker)
                }
            }
        }
        .navigationTitle("Personnel Management")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewmodel.showAddSupervisorSheet) {
            AddSupervisorView()
        }
        .onAppear {
            Task {
                await MainActor.run {
                    if viewmodel.isLoading {
                        ProgressView("Fetching Supervisor...")
                    }
                }
                await viewmodel.getSupervisor()
            }
        }
    }
}

#Preview {
    PHPersonnelView()
}
