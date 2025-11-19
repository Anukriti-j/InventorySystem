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
                Section("Factory Information") {
                    if userRole == .owner {
                        Picker("Select Factory", selection: $viewModel.factoryID) {
                            Text("Select a factory").tag(0)
                            ForEach(listViewModel.factories) { factory in
                                Text(factory.factoryName).tag(factory.id)
                            }
                        }
                        .onChange(of: viewModel.factoryID) { oldValue, newValue in
                            guard newValue != oldValue, newValue != 0 else { return }
                            viewModel.validateFactory()
                            viewModel.bays = []
                            viewModel.bayID = 0
                            Task { @MainActor in
                                await viewModel.getWorkersBay()
                            }
                        }
                        
                        if let error = viewModel.factoryError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    if !viewModel.bays.isEmpty {
                        Picker("Select Bay", selection: $viewModel.bayID) {
                            Text("Select a bay").tag(0)
                            ForEach(viewModel.bays) { bay in
                                Text(bay.bayName).tag(bay.id)
                            }
                        }
                        .onChange(of: viewModel.bayID) { oldValue, newValue in
                            guard newValue != oldValue, newValue != 0 else { return }
                            viewModel.validateBay()
                        }
                        
                        if let error = viewModel.bayError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                
                Section("Worker Details") {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Name", text: $viewModel.name)
                            .autocapitalization(.words)
                        if let error = viewModel.nameError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        if let error = viewModel.emailError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }
                }
                
                Section("Worker Image") {
                    AddImageView(selectedImage: $viewModel.selectedImage)
                }
            }
            .navigationTitle("Create Worker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .tint(.red)
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
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
                                .scaleEffect(0.9)
                        } else {
                            Text("Add")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoadingWorker)
                }
            }
            .disabled(viewModel.isLoadingWorker) // Prevent interaction during submit
            .overlay {
                if viewModel.isLoadingWorker {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay {
                            ProgressView("Creating worker...")
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                }
            }
        }
        .onAppear {
            // Only load bays if not owner AND factory is fixed
            if userRole != .owner {
                Task { @MainActor in
                    await viewModel.getWorkersBay()
                }
            }
        }
    }
}
