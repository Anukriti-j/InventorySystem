import SwiftUI

struct AddPlantHeadView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddPlantHeadViewModel()
    @State private var selectedFactoryID: Int? = nil
    @State private var isLoading = false
    
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
                    if isLoading {
                        ProgressView("Loading factories...")
                    } else {
                        let factoryLabel: String = {
                            if let id = selectedFactoryID,
                               let name = viewModel.unassignedFactories.first(where: { $0.factoryID == id })?.factoryName {
                                return name
                            } else {
                                return "Select factory"
                            }
                        }()

                        Picker(selection: $selectedFactoryID, label: Text(factoryLabel)) {
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        Task {
                            guard let factoryID = selectedFactoryID else {
                                await MainActor.run() {
                                    viewModel.alertMessage = "Please select a factory"
                                    viewModel.showAlert = true
                                }
                                return
                            }
                            await viewModel.createPlantHead(factoryID: factoryID)
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.getUnassignedFactories()
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
    AddPlantHeadView()
}
