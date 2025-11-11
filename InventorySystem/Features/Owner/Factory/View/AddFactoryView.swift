import SwiftUI

struct AddFactoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddFactoryViewModel()

    var body: some View {
        NavigationStack {
            Form {
                factoryDetailsSection
                if viewModel.isFetchingPlantHeads {
                    ProgressView()
                } else {
                    plantHeadSection
                }
            }
            .navigationTitle("Add Factory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await saveFactory()
                        }
                    } label: {
                        if viewModel.isSavingFactory {
                            ProgressView()
                        } else { Text("Save") }
                    }
                    .disabled(!viewModel.isFormValid)
                    .bold()
                }
            }
        }
        .onAppear(perform: {
            Task {
                print("on appear get all ph called")
             await viewModel.getAllPlantHeads()
            }
        })
        .alert(viewModel.alertMessage ?? "Message", isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.success {
                    dismiss()
                }
            }
        }
    }
}

extension AddFactoryView {
    
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
    
    private var factoryDetailsSection: some View {
        Section(header: Text("Factory Details")) {
            TextField("Factory Name", text: $viewModel.name)
            TextField("City", text: $viewModel.city)
            TextField("Address", text: $viewModel.address, axis: .vertical)
                .lineLimit(2...4)
        }
    }
    
    private var plantHeadSection: some View {
        Section(header: Text("Plant Head")) {
            Picker("Select Plant Head", selection: $viewModel.plantHeadID) {
                Text("Select").tag(Optional<Int>.none)
                ForEach(viewModel.activePlantHeads) { plantHead in
                    Text(plantHead.username).tag(plantHead.id)
                }
            }
        }
    }
}

#Preview {
    AddFactoryView()
}
