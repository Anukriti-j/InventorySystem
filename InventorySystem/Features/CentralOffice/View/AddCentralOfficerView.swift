import SwiftUI

struct AddCentralOfficerView: View {
    @StateObject private var viewModel = AddCentralOfficerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(StringConstants.officerDetail)) {
                    VStack(alignment: .leading, spacing: 8) {
                        COInputField(label: StringConstants.name, text: $viewModel.name)
                        if let error = viewModel.nameError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        COInputField(label: StringConstants.email, text: $viewModel.email)
                        if let error = viewModel.emailError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle(StringConstants.addOfficer)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(StringConstants.cancel) {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if viewModel.isFormValid {
                            Task {
                                await viewModel.createCentralOfficer()
                                if viewModel.success {
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().scaleEffect(0.9)
                        } else {
                            Text(StringConstants.save).fontWeight(.semibold)
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .alert(viewModel.alertMessage ?? StringConstants.messageTitle, isPresented: $viewModel.showAlert) {
                Button(StringConstants.ok, role: .cancel) {}
            }
        }
    }
}

struct COInputField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            
            TextField("Enter \(label.lowercased())", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.systemBackground).opacity(0.9))
                .cornerRadius(12)
        }
    }
}
