import SwiftUI

struct EditFactoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditFactoryViewModel
    @Bindable var factoryViewModel: OwnerFactoryViewModel
    
    init(factory: Factory, factoryViewModel: OwnerFactoryViewModel) {
        _viewModel = StateObject(wrappedValue: EditFactoryViewModel(factory: factory))
        self.factoryViewModel = factoryViewModel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                factoryDetailsSection
                plantHeadSection
            }
            .disabled(viewModel.isLoading)
            .navigationTitle("Edit Factory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Update", action: updateFactory)
                        .disabled(!viewModel.isFormValid || !viewModel.hasChanges)
                        .bold()
                }
            }
            .alert("Update Status", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
            .onAppear {
                Task { await viewModel.getAllPlantHeads() }
            }
        }
    }
}

private extension EditFactoryView {
    var factoryDetailsSection: some View {
        Section(header: Text("Factory Details")) {
            TextField("Factory Name", text: $viewModel.factoryName)
            TextField("Location", text: $viewModel.location)
            TextField("Address", text: $viewModel.address, axis: .vertical)
                .lineLimit(2...4)
        }
    }
    
    var plantHeadSection: some View {
        Section(header: Text("Plant Head")) {
            Picker("Select Plant Head", selection: $viewModel.plantHeadID) {
                Text("Select a Plant Head").tag(nil as Int?) // placeholder option
                ForEach(viewModel.activePlantHeads, id: \.id) { plantHead in
                    Text(plantHead.username)
                        .tag(plantHead.id)
                }
            }
        }
    }
}

private extension EditFactoryView {
    func updateFactory() {
        Task {
            await viewModel.updateFactory()
            if viewModel.updateSuccess {
                await factoryViewModel.fetchFactories(reset: true)
                dismiss()
            }
        }
    }
}
