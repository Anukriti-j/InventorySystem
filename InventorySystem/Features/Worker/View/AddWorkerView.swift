import SwiftUI

struct AddWorkerView: View {
    @State private var viewModel: AddWorkerViewModel
    @Bindable var listViewModel: WorkerViewModel
    @Environment(\.dismiss) private var dismiss
    
    let factoryId: Int?
    let userRole: UserRole
    
    init(factoryId: Int?, userRole: UserRole, listViewModel: WorkerViewModel) {
        self.factoryId = factoryId
        self.userRole = userRole
        _viewModel = State(wrappedValue: AddWorkerViewModel(factoryId: factoryId))
        self.listViewModel = listViewModel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Factory Information")) {
                    
                    if userRole == .owner {
                        Picker("Select Factory", selection: $viewModel.factoryID) {
                            Text("Select a factory").tag(0)
                            ForEach(listViewModel.factories) { factory in
                                Text(factory.factoryName).tag(factory.id)
                            }
                        }
                        .onChange(of: viewModel.factoryID) { _ in
                            viewModel.bays = []
                            viewModel.bayID = 0
                            Task { await viewModel.getWorkersBay() }
                        }
                    }
                    
                    if !viewModel.bays.isEmpty {
                        Picker("Select Bay", selection: $viewModel.bayID) {
                            Text("Select a bay").tag(0)
                            ForEach(viewModel.bays) { bay in
                                Text(bay.bayName).tag(bay.id)
                            }
                        }
                    }
                }
                
                Section(header: Text("Worker Details")) {
                    TextField("Name", text: $viewModel.name)
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Worker Image")) {
                    AddImageView(selectedImage: $viewModel.selectedImage)
                }
            }
            .navigationTitle("Create Worker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Leading: Cancel button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                // Trailing: Add button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.addWorker()
                            if viewModel.success {
                                await listViewModel.fetchAllWorkers(reset: true)
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isLoadingWorker {
                            ProgressView()
                        } else {
                            Text("Add")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(viewModel.factoryID == 0 ||
                              viewModel.bayID == 0 ||
                              viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty ||
                              viewModel.email.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            if userRole != .owner {
                Task { await viewModel.getWorkersBay() }
            }
        }
    }
}
