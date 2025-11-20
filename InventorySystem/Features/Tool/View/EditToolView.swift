import SwiftUI
import Kingfisher

struct EditToolView: View {
    @State private var viewModel: EditToolViewModel
    @Environment(\.dismiss) private var dismiss
    @Bindable var parentViewModel: ToolsListViewModel
    
    init(tool: Tool, parentViewModel: ToolsListViewModel) {
        self.parentViewModel = parentViewModel
        _viewModel = State(wrappedValue: EditToolViewModel(tool: tool))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    AddImageView(selectedImage: $viewModel.selectedImage, urlString: viewModel.toolImageURL)
                        .frame(height: 180)
                        .clipped()
                    
                    VStack(spacing: 16) {
                        
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Tool Name", text: $viewModel.name)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.words)
                            
                            if let error = viewModel.nameError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Description", text: $viewModel.description, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
                            
                            if let error = viewModel.descriptionError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Picker("Category", selection: Binding(
                                get: { viewModel.selectedCategoryID },
                                set: { viewModel.selectedCategoryID = $0 }
                            )) {
                                Text("Select category")
                                    .foregroundColor(.secondary)
                                    .tag(Optional<Int>(nil))
                                
                                ForEach(viewModel.categories) { category in
                                    Text(category.categoryName)
                                        .tag(Optional(category.id))
                                }
                            }
                            .pickerStyle(.menu)
                            
                            if let error = viewModel.categoryError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                        Stepper("Threshold: \(viewModel.threshold)", value: $viewModel.threshold, in: 0...50)
                        
                        Toggle("Is Perishable", isOn: $viewModel.isPerishableBool)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                        
                        Toggle("Is Expensive", isOn: $viewModel.isExpensiveBool)
                            .toggleStyle(SwitchToggleStyle(tint: .red))
                    }
                    .padding(.horizontal)
                    
                    Button {
                        Task {
                            await viewModel.updateTool()
                            if viewModel.success {
                                await parentViewModel.fetchTools(reset: true)
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Update Tool")
                                .foregroundColor(.white)
                        }
                    }
                    .customStyle(isDisabled: !viewModel.isFormValid || !viewModel.hasChanges || viewModel.isLoading)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading || !viewModel.hasChanges)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .navigationTitle("Edit Tool")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel", role: .cancel) { dismiss() }
                            .foregroundColor(.red)
                    }
                }
            }
            .alert(viewModel.alertMessage ?? "Message", isPresented: $viewModel.showAlert) {
                Button("OK") {
                    if viewModel.success { dismiss() }
                }
            }
        }
        .onAppear {
            Task { await viewModel.getCategories() }
        }
    }
}
