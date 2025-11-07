import SwiftUI

struct AddFactoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddFactoryViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Factory Details")) {
                    TextField("Factory Name", text: $viewModel.name)
                    TextField("City", text: $viewModel.city)
                    TextField("Address", text: $viewModel.address, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section(header: Text("Plant Head")) {
                    Picker("Select Plant Head", selection: $viewModel.plantHeadID) {
                        Text("Select").tag(nil as Int?)
                        ForEach(viewModel.plantHeads, id: \.id) { head in
                            Text(head.name).tag(head.id as Int?)
                        }
                    }
                }
            }
            .navigationTitle("Add Factory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveFactory()
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                    .bold()
                }
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
    
    // MARK: - Helper
    
    private func saveFactory() async {
        await viewModel.createFactory()
        
        await MainActor.run {
            if viewModel.success {
                viewModel.alertMessage = "Factory created successfully!"
            } else {
                viewModel.alertMessage = "Failed to create factory."
            }
            viewModel.showAlert = true
        }
    }
}

#Preview {
    AddFactoryView()
}
