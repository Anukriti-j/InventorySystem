import SwiftUI
import Kingfisher

struct EditMerchandiseView: View {
    @State private var viewModel: EditMerchandiseViewModel
    @Bindable var parentViewModel: MerchandiseViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(merchandise: Merchandise, parentViewModel: MerchandiseViewModel) {
        self.parentViewModel = parentViewModel
        _viewModel = State(wrappedValue: EditMerchandiseViewModel(merchandise: merchandise))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    AddImageView(selectedImage: $viewModel.selectedImage, urlString: viewModel.merchandiseImageURL)
                        .frame(height: 180)
                        .clipped()
                    
                    VStack(spacing: 16) {
                        
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Name", text: $viewModel.name)
                                .autocapitalization(.words)
                            if let error = viewModel.nameError, viewModel.name != viewModel.originalName {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Required Points", value: $viewModel.requiredPoints, format: .number)
                                .keyboardType(.numberPad)
                            if let error = viewModel.requiredPointError, viewModel.requiredPoints != viewModel.originalRequiredPoints {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Available Quantity", value: $viewModel.availableQuantity, format: .number)
                                .keyboardType(.numberPad)
                            if let error = viewModel.availQuantityError, viewModel.availableQuantity != viewModel.originalAvailableQuantity {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Button {
                        Task {
                            await viewModel.updateMerchandise()
                            if viewModel.success {
                                await parentViewModel.fetchMerchandise(reset: true)
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Update Merchandise")
                                .foregroundColor(.white)
                        }
                    }
                    .customStyle(isDisabled: !viewModel.isFormValid || !viewModel.hasChanges() || viewModel.isLoading)
                    .disabled(!viewModel.isFormValid || !viewModel.hasChanges() || viewModel.isLoading)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .navigationTitle("Edit Merchandise")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel", role: .cancel) { dismiss() }
                            .foregroundColor(.red)
                    }
                }
                .alert(viewModel.alertMessage ?? "", isPresented: $viewModel.showAlert) {
                    Button("OK") {
                        if viewModel.success { dismiss() }
                    }
                }
            }
        }
    }
}
