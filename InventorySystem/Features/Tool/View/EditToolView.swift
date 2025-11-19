import SwiftUI
import Kingfisher

struct EditToolView: View {
    @StateObject private var viewModel: EditToolViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(tool: Tool) {
        _viewModel = StateObject(wrappedValue: EditToolViewModel(tool: tool))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                AddImageView(selectedImage: $viewModel.selectedImage, urlString: viewModel.toolImageURL)
                    .frame(height: 180)
                    .clipped()
                
                VStack(spacing: 16) {
                    TextField("Tool Name", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                    
                    TextField("Description", text: $viewModel.description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                    
                    Picker("Category", selection: $viewModel.selectedCategoryID) {
                        if viewModel.selectedCategoryID == nil {
                            Text("Select category")
                                .foregroundColor(.secondary)
                                .tag(Optional<Int>(nil))
                        }
                        
                        ForEach(viewModel.categories) { category in
                            Text(category.categoryName)
                                .tag(Optional(category.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden() // hides the "Category" label inside picker
                    
                    Stepper("Threshold: \(viewModel.threshold)", value: $viewModel.threshold, in: 0...50)
                    Stepper("Available Quantity: \(viewModel.availableQuantity)", value: $viewModel.availableQuantity, in: 0...1000)
                    
                    Toggle("Is Perishable", isOn: $viewModel.isPerishableBool)
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                    
                    Toggle("Is Expensive", isOn: $viewModel.isExpensiveBool)
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                }
                .padding(.horizontal)
                
                // Update Button
                Button {
                    Task { await viewModel.updateTool() }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Update Tool")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isFormValid ? Color.purple : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Edit Tool")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", role: .cancel) { dismiss() }
                    .foregroundColor(.red)
            }
        }
        .alert(viewModel.alertMessage ?? "", isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.success { dismiss() }
            }
        }
        .onAppear {
            Task { await viewModel.getCategories() }
        }
    }
}
