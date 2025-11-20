import SwiftUI

enum Mode {
    case add, edit
}

struct AddOrUpdateProductView: View {
    @StateObject private var viewModel: AddOrUpdateProductViewModel
    @Environment(\.dismiss) private var dismiss
    let parentViewModel: ProductsViewModel
    let mode: Mode
    let product: Product?
    
    init(parentViewModel: ProductsViewModel, mode: Mode, product: Product? = nil) {
        self.mode = mode
        self.product = product
        self.parentViewModel = parentViewModel
        _viewModel = StateObject(wrappedValue: AddOrUpdateProductViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    AddImageView(selectedImage: $viewModel.selectedImage)
                    
                    VStack(spacing: 16) {
                        
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Product Name", text: $viewModel.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if let error = viewModel.nameError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Description", text: $viewModel.productDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if let error = viewModel.descriptionError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        
                        handleCategoryPicker()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Price", text: $viewModel.price)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            
                            if let error = viewModel.priceError {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Button {
                        Task {
                            switch mode {
                            case .add:
                                await viewModel.createOrUpdateProduct(productId: product?.id, mode: .add)
                            case .edit:
                                await viewModel.createOrUpdateProduct(productId: product?.id, mode: .edit)
                            }
                            if viewModel.success {
                                await parentViewModel.fetchProducts(reset: true)
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            switch mode {
                            case .add:
                                Text("Create Product")
                                    .foregroundColor(.white)
                            case .edit:
                                Text("Update Product")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .customStyle(isDisabled: !viewModel.isFormValid)
                    .padding(.horizontal)
                    .disabled(!viewModel.isFormValid)
                }
                .padding(.vertical)
            }
            .navigationTitle(mode == .add ? "Add Product": "Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
            }
            .alert(StringConstants.messageTitle, isPresented: $viewModel.showAlert) {
                Button(StringConstants.ok) {
                    if viewModel.success { dismiss() }
                }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
            .onAppear {
                Task { await viewModel.getProductCategories() }
            }
        }
    }
    
    @ViewBuilder
    private func handleCategoryPicker() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Category")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("Select Category", selection: Binding<Int?>(
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
                
                ForEach(viewModel.categories) { category in
                    Text(category.categoryName)
                        .tag(Optional(category.id))
                }
                
                Text("+ Add New Category").tag(Optional(-1))
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3))
            )
            .tint(.purple)
            
            if let error = viewModel.categoryError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if viewModel.isAddingNewCategory {
                TextField("Enter new category name", text: Binding(
                    get: { viewModel.newCategoryName ?? "" },
                    set: { viewModel.newCategoryName = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top, 4)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: viewModel.isAddingNewCategory)
    }
}
