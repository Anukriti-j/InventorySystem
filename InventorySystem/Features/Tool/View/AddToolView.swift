import SwiftUI

struct AddToolView: View {
    @StateObject private var viewModel = AddToolViewModel()
    @Environment(\.dismiss) private var dismiss
    @Bindable var parentViewModel: ToolsListViewModel
    
    init(parentViewModel: ToolsListViewModel) {
        self.parentViewModel = parentViewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    AddImageView(selectedImage: $viewModel.selectedImage)
                    
                    VStack(spacing: 16) {
                        
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Tool Name", text: $viewModel.name)
                                .textFieldStyle(.roundedBorder)
                            if let error = viewModel.nameError {
                                Text(error).foregroundColor(.red).font(.caption)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Description", text: $viewModel.description, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
                        }
                        
                        handleCategoryPicker()
                        
                        Stepper("Threshold: \(viewModel.threshold)", value: $viewModel.threshold, in: 0...50)
                        
                        Toggle("Is Perishable", isOn: $viewModel.isPerishableBool)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                        
                        Toggle("Is Expensive", isOn: $viewModel.isExpensiveBool)
                            .toggleStyle(SwitchToggleStyle(tint: .red))
                    }
                    .padding(.horizontal)
                    
                    Button {
                        Task { await viewModel.createTool() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Tool")
                                .foregroundColor(.white)
                        }
                    }
                    .customStyle(isDisabled: !viewModel.isFormValid || viewModel.isLoading)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Add Tool")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
            }
            .alert("Tool Creation", isPresented: $viewModel.showAlert) {
                Button("OK") {
                    if viewModel.success {
                        Task {
                            await  parentViewModel.fetchTools(reset: true)
                        }
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.alertMessage)
            }
            .onAppear {
                Task { await viewModel.getCategories() }
            }
        }
    }
    
    @ViewBuilder
    private func handleCategoryPicker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("Category", selection: Binding<Int?>(
                get: { viewModel.isAddingNewCategory ? -1 : viewModel.selectedCategoryID },
                set: { newValue in
                    if newValue == -1 {
                        viewModel.isAddingNewCategory = true
                        viewModel.selectedCategoryID = nil
                    } else {
                        viewModel.isAddingNewCategory = false
                        viewModel.selectedCategoryID = newValue
                    }
                }
            )) {
                Text("Select a category").tag(Optional<Int>(nil))
                ForEach(viewModel.categories) { cat in
                    Text(cat.categoryName).tag(Optional(cat.id))
                }
                Text("+ Add New Category").tag(Optional(-1))
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
            .tint(.purple)
            
            if let error = viewModel.categoryError {
                Text(error).foregroundColor(.red).font(.caption)
            }
            
            if viewModel.isAddingNewCategory {
                TextField("New category name", text: Binding(
                    get: { viewModel.newCategoryName ?? "" },
                    set: { viewModel.newCategoryName = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: viewModel.isAddingNewCategory)
    }
}
