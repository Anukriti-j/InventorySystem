import SwiftUI
import Kingfisher

struct EditMerchandiseView: View {
    @State private var viewModel: EditMerchandiseViewModel
    @Environment(\.dismiss) private var dismiss
    private let merchandise: Merchandise
    
    init(merchandise: Merchandise) {
        _viewModel = State(wrappedValue: EditMerchandiseViewModel(merchandise: merchandise))
        self.merchandise = merchandise
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                AddImageView(selectedImage: $viewModel.selectedImage, urlString: viewModel.merchandiseImageURL)
                
                VStack(spacing: 16) {
                    TextField("Name", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                    TextField("Required points", value: $viewModel.requiredPoints, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    TextField("Available quantity", value: $viewModel.availableQuantity, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
            }
            .padding(.horizontal).navigationTitle("Edit Merchandise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) { dismiss() }
                        .foregroundColor(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.updateMerchandise() }
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Update Merchandise")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .disabled(viewModel.isLoading || viewModel.hasChanges())
                }
            }
            .alert(viewModel.alertMessage ?? "", isPresented: $viewModel.showAlert) {
                Button("OK") {
                    if viewModel.success { dismiss() }
                }
            }
        }
        .padding(.vertical)
    }
}
