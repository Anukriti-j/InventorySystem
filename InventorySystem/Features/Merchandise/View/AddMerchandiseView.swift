import SwiftUI

struct AddMerchandiseView: View {
    @State private var viewModel = AddMerchandiseViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            AddImageView(selectedImage: $viewModel.selectedImage)
            
            Form {
                
                Section("Details") {
                    
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
                        TextField("Required points", value: $viewModel.requiredPoints, format: .number)
                            .keyboardType(.numberPad)
                        
                        if let error = viewModel.requiredPointError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Available quantity", value: $viewModel.availableQuantity, format: .number)
                            .keyboardType(.numberPad)
                        
                        if let error = viewModel.availQuantityError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
            }
            .navigationTitle("Add Merchandise")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if viewModel.isFormValid() {
                            Task {
                                await viewModel.createMerchandise()
                            }
                        }
                        
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Save")
                                .fontWeight(.bold)
                        }
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Adding Merchandise"),
                    message: Text(viewModel.alertMessage ?? ""),
                    dismissButton: .default(Text("OK"), action: { dismiss() })
                )
            }
        }
    }
}
