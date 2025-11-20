import SwiftUI

struct AddPlantHeadView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddPlantHeadViewModel()
    @Bindable var parentViewModel: PlantHeadListViewModel
    @State private var selectedFactoryID: Int? = nil
    
    init(parentViewModel: PlantHeadListViewModel, selectedFactoryID: Int? = nil) {
        self.parentViewModel = parentViewModel
        self.selectedFactoryID = selectedFactoryID
    }
    
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
                
                Section(header: Text("Assign to Factory")) {
                    if viewModel.isLoadingFactories {
                        ProgressView("Loading factories...")
                    } else {
                        Picker(selection: $selectedFactoryID, label: Text(selectedFactoryName)) {
                            Text("Select").tag(Optional<Int>.none)
                            ForEach(viewModel.unassignedFactories, id: \.factoryID) { factory in
                                Text(factory.factoryName).tag(Optional(factory.factoryID))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
            }
            .navigationTitle("Add Plant Head")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        createPlantHead()
                    } label: {
                        if viewModel.isCreating {
                            ProgressView()
                        } else {
                            Text("Add")
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
        .onAppear {
            Task { await viewModel.getUnassignedFactories() }
        }
        .alert(viewModel.alertMessage ?? "Message", isPresented: $viewModel.showAlert) {
            Button("OK") { if viewModel.success { dismiss() } }
        }
    }
    
    private var selectedFactoryName: String {
        if let id = selectedFactoryID,
           let name = viewModel.unassignedFactories.first(where: { $0.factoryID == id })?.factoryName {
            return name
        }
        return "Select factory"
    }
    
    private func createPlantHead() {
        Task {
            if !viewModel.unassignedFactories.isEmpty {
                guard let factoryID = selectedFactoryID else {
                    await MainActor.run {
                        viewModel.alertMessage = "Please select a factory"
                        viewModel.showAlert = true
                    }
                    return
                }
                await viewModel.createPlantHead(factoryID: factoryID)
            } else {
                await viewModel.createPlantHead()
            }
            
            if viewModel.success {
                await parentViewModel.fetchPlantHeads(reset: true)
            }
        }
    }
}

#Preview {
    AddPlantHeadView(parentViewModel: PlantHeadListViewModel())
}
