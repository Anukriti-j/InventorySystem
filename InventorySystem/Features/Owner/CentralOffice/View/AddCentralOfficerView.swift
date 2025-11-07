import SwiftUI

struct AddCentralOfficerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddCentralOfficerViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Central Officer Details")) {
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
            .navigationTitle("Add Central Officer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.createCentralOfficer() }
                    } label: {
                        Text("Save").bold()
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
    AddCentralOfficerView()
}
