import SwiftUI

struct AddCentralOfficerView: View {
    @StateObject private var viewModel = AddCentralOfficerViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Officer Details")) {
                    VStack(alignment: .leading, spacing: 8) {
                        COInputField(label: "Name", text: $viewModel.name)
                        if let error = viewModel.nameError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        COInputField(label: "Email", text: $viewModel.email)
                        if let error = viewModel.emailError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Add Officer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
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
                            Text("Save").fontWeight(.semibold)
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .alert(viewModel.alertMessage ?? "Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
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
