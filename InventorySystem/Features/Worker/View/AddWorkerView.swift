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
            AddImageView(selectedImage: $viewModel.selectedImage)
            Form {
                Section("Factory Information") {
                    if userRole == .owner {
                        VStack(alignment: .leading, spacing: 6) {
                            Picker("Select Factory", selection: $viewModel.factoryID) {
                                Text("Select a factory").tag(0)
                                ForEach(listViewModel.factories) { factory in
                                    Text(factory.factoryName).tag(factory.id)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            if let error = viewModel.factoryError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        .onChange(of: viewModel.factoryID) { _, newValue in
                            guard newValue != 0 else { return }
                            viewModel.bays = []
                            viewModel.bayID = 0
                            Task { await viewModel.getWorkersBay() }
                        }
                    }
                    
                    if !viewModel.bays.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Picker("Select Bay", selection: $viewModel.bayID) {
                                Text("Select a bay").tag(0)
                                ForEach(viewModel.bays) { bay in
                                    Text(bay.bayName).tag(bay.id)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            if let error = viewModel.bayError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                Section("Worker Details") {
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Name", text: $viewModel.name)
                            .autocapitalization(.words)
                        if let error = viewModel.nameError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        if let error = viewModel.emailError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }
                }
                
            }
            .navigationTitle("Create Worker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
                
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
                                .scaleEffect(0.9)
                        } else {
                            Text("Add")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoadingWorker)
                }
            }
            .disabled(viewModel.isLoadingWorker)
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
            .alert("Message", isPresented: $viewModel.showAlert) {
                Button("OK") {
                    if viewModel.success { dismiss() }
                }
            } message: {
                Text(viewModel.alertMessage ?? "An error occurred")
            }
            .onAppear {
                if userRole != .owner {
                    Task { await viewModel.getWorkersBay() }
                }
            }
        }
    }
}
