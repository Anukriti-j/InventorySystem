import SwiftUI

struct AddSupervisorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = AddSupervisorViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Chief Supervisor Details")) {
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Name", text: $viewModel.name)
                            .autocapitalization(.words)
                            
                        if let error = viewModel.nameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        if let error = viewModel.emailError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Add Chief Supervisor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        Task {
                            guard let factoryID = FactorySessionManager.shared.selectedFactoryID else {
                                viewModel.alertMessage = "Please select a factory first"
                                viewModel.showAlert = true
                                return
                            }
                            await viewModel.addChiefSupervisor(factoryID: factoryID)
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
        .alert(viewModel.alertMessage ?? "Message", isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.success { dismiss() }
            }
        }
    }
}

#Preview {
    AddSupervisorView()
}
