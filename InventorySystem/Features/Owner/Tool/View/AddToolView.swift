import SwiftUI

struct AddToolView: View {
    @StateObject private var viewModel = AddToolViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    ToolImageView(selectedImage: $viewModel.selectedImage)
                    
                    VStack(spacing: 16) {
                        TextField("Tool Name", text: $viewModel.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Description", text: $viewModel.description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        handleCategoryPicker()
                        
                        Stepper("Threshold: \(viewModel.threshold)", value: $viewModel.threshold, in: 0...50)
                            .padding(.vertical, 4)
                        
                        Toggle("Is Perishable", isOn: Binding(
                            get: { viewModel.isPerishable.uppercased() == "YES" },
                            set: { viewModel.isPerishable = $0 ? "YES" : "NO" }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .purple))

                        Toggle("Is Expensive", isOn: Binding(
                            get: { viewModel.isExpensive.uppercased() == "YES" },
                            set: { viewModel.isExpensive = $0 ? "YES" : "NO" }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                    }
                    .padding(.horizontal)
                    
                    Button {
                        Task { await viewModel.createTool() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(10)
                        } else {
                            Text("Create Tool")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)
                }
                .padding(.vertical)
            }
            .navigationTitle("Add Tool")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Tool Creation"),
                    message: Text(viewModel.alertMessage ?? ""),
                    dismissButton: .default(Text("OK"), action: { dismiss() })
                )
            }
        }
        .onAppear {
            Task { await viewModel.getCategories() }
        }
    }
}

extension AddToolView {
    func handleCategoryPicker() -> some View {
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
                // Categories
                ForEach(viewModel.categories, id: \.id) { category in
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
