import SwiftUI

struct AddFactoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var addFactoryViewModel = AddFactoryViewModel()
    @Bindable var ownerFactoryViewModel: FactoryViewModel

    var body: some View {
        NavigationStack {
            Form {
                factoryDetailsSection
                if addFactoryViewModel.isFetchingPlantHeads {
                    ProgressView()
                } else {
                    plantHeadSection
                }
            }
            .navigationTitle("Add Factory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await saveFactory()
                            if addFactoryViewModel.success {
                                await ownerFactoryViewModel.fetchFactories(reset: true)
                            }
                        }
                    } label: {
                        if addFactoryViewModel.isSavingFactory {
                            ProgressView()
                        } else { Text("Save") }
                    }
                    .disabled(!addFactoryViewModel.isFormValid)
                    .bold()
                }
            }
        }
        .onAppear(perform: {
            Task {
             await addFactoryViewModel.getAllPlantHeads()
            }
        })
        .alert(addFactoryViewModel.alertMessage ?? "Message", isPresented: $addFactoryViewModel.showAlert) {
            Button("OK") {
                if addFactoryViewModel.success {
                    dismiss()
                }
            }
        }
    }
}

extension AddFactoryView {
    
    private func saveFactory() async {
        await addFactoryViewModel.createFactory()
        
        await MainActor.run {
            if addFactoryViewModel.success {
                addFactoryViewModel.alertMessage = "Factory created successfully!"
            } else {
                addFactoryViewModel.alertMessage = "Failed to create factory."
            }
            addFactoryViewModel.showAlert = true
        }
    }
    
    private var factoryDetailsSection: some View {
        Section(header: Text("Factory Details")) {
            TextField("Factory Name", text: $addFactoryViewModel.name)
            TextField("City", text: $addFactoryViewModel.city)
            TextField("Address", text: $addFactoryViewModel.address, axis: .vertical)
                .lineLimit(2...4)
        }
    }
    
    private var plantHeadSection: some View {
        Section(header: Text("Plant Head")) {
            Picker("Select Plant Head", selection: $addFactoryViewModel.plantHeadID) {
                Text("Select").tag(Optional<Int>.none)
                ForEach(addFactoryViewModel.activePlantHeads) { plantHead in
                    Text(plantHead.username).tag(plantHead.id)
                }
            }
        }
    }
}

//#Preview {
//    AddFactoryView()
//}
