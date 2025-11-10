import SwiftUI

struct AddCentralOfficerView: View {
    @Environment(\.dismiss) private var dismiss
   @StateObject private var viewModel = AddCentralOfficerViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Full Name", text: $viewModel.name)
                            .textContentType(.name)
                            .autocorrectionDisabled()
                        
                        if let error = viewModel.nameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Email Address", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        
                        if let error = viewModel.emailError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("Officer Information")
                } 
            }
            .navigationTitle("Add Central Officer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await  viewModel.createCentralOfficer()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isFormValid)
                }
            }
            .alert(viewModel.alertMessage ?? "Message", isPresented: $viewModel.showAlert) {
                Button("OK") {
                    if viewModel.success {
                        dismiss()
                    }
                }
            }
        }
    }
}
