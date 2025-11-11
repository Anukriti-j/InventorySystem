//import SwiftUI
//
//struct EditFactoryView: View {
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var viewModel: EditFactoryViewModel
//
//    let onUpdate: ((Factory) -> Void)?
//
//    // MARK: - Init
//    init(factory: Factory,
//         onUpdate: ((Factory) -> Void)? = nil) {
//        _viewModel = StateObject(wrappedValue: EditFactoryViewModel(factory: factory))
//        self.onUpdate = onUpdate
//    }
//
//    // MARK: - Body
//    var body: some View {
//        NavigationStack {
//            Form {
//                factoryDetailsSection
//                plantHeadSection
//            }
//            .disabled(viewModel.isLoading)
//            .navigationTitle("Edit Factory")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItemGroup(placement: .topBarLeading) {
//                    Button("Cancel") { dismiss() }
//                }
//
//                ToolbarItemGroup(placement: .topBarTrailing) {
//                    Button("Update", action: updateFactory)
//                        .disabled(!viewModel.isFormValid || !viewModel.hasChanges)
//                        .bold()
//                }
//            }
//            .alert("Update Status", isPresented: $viewModel.showAlert) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text(viewModel.alertMessage ?? "")
//            }
//        }
//    }
//}
//
//// MARK: - View Components
//private extension EditFactoryView {
//    var factoryDetailsSection: some View {
//        Section(header: Text("Factory Details")) {
//            TextField("Factory Name", text: $viewModel.name)
//            TextField("City", text: $viewModel.city)
//            TextField("Address", text: $viewModel.address, axis: .vertical)
//                .lineLimit(2...4)
//        }
//    }
//
//    var plantHeadSection: some View {
//        Section(header: Text("Plant Head")) {
//            Picker("Select Plant Head", selection: $viewModel.plantHeadID) {
//                ForEach(viewModel.activePlantHeads, id: \.id) { plantHead in
//                    Text(plantHead.username)
//                        .tag(plantHead.id)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Actions
//private extension EditFactoryView {
//    func updateFactory() {
//        Task {
//            await viewModel.updateFactory()
//            if viewModel.updateSuccess {
////                onUpdate?(viewModel.toUpdatedFactory())
//                dismiss()
//            }
//        }
//    }
//}
