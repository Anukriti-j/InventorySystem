import SwiftUI

struct AddPlantHeadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddPlantHeadViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Plant Head Details")) {
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
            .navigationTitle("Add Plant Head")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await savePlantHead() }
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

extension AddPlantHeadView {
    private func savePlantHead() async {
        await viewModel.createPlantHead()
        
        await MainActor.run {
            if viewModel.success {
                viewModel.alertMessage = "Plant Head created successfully!"
            } else {
                viewModel.alertMessage = "Failed to create Plant Head."
            }
            viewModel.showAlert = true
        }
    }
}

#Preview {
    AddPlantHeadView()
}
