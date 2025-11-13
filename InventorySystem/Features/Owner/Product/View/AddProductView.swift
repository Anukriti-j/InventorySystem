import SwiftUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Image
                    ToolImageView(selectedImage: $viewModel.selectedImage)

                    // MARK: - Form Fields
                    VStack(spacing: 16) {
                        TextField("Product Name", text: $viewModel.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Description", text: $viewModel.productDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        handleCategoryPicker()

                        TextField("Price", text: $viewModel.price)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    .padding(.horizontal)

                    // MARK: - Create Button
                    Button {
                        Task { await viewModel.createProduct() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(10)
                        } else {
                            Text("Create Product")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading || viewModel.name.isEmpty || viewModel.price.isEmpty)
                }
                .padding(.vertical)
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("Product Creation", isPresented: $viewModel.showAlert) {
                Button("OK") {
                    if viewModel.success {
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
            .onAppear {
                Task { await viewModel.getProductCategories() }
            }
        }
    }

    // MARK: - Category Picker (Same as Tool)
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

                Text("+ Add New Category")
                    .tag(Optional(-1))
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
