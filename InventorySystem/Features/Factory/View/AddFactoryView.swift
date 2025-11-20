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
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("Loading plant heads...")
                            Spacer()
                        }
                    }
                } else {
                    plantHeadSection
                }
            }
            .navigationTitle("Add Factory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await saveFactory() }
                    } label: {
                        if addFactoryViewModel.isSavingFactory {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!addFactoryViewModel.isFormValid || addFactoryViewModel.isSavingFactory)
                }
            }
            .alert(addFactoryViewModel.alertMessage, isPresented: $addFactoryViewModel.showAlert) {
                Button("OK") {
                    if addFactoryViewModel.success { dismiss() }
                }
            }
            .onAppear {
                Task {
                    await addFactoryViewModel.getAllPlantHeads()
                    await ownerFactoryViewModel.getLocations() // fetch locations
                }
            }
        }
    }

    private func saveFactory() async {
        await addFactoryViewModel.createFactory()
        if addFactoryViewModel.success {
            await ownerFactoryViewModel.fetchFactories(reset: true)
        }
    }

    private var factoryDetailsSection: some View {
        Section("Factory Details") {
            VStack(alignment: .leading, spacing: 6) {
                TextField("Factory Name", text: $addFactoryViewModel.name)
                if let error = addFactoryViewModel.nameError {
                    Text(error).foregroundColor(.red).font(.caption)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Picker("Select Location", selection: $addFactoryViewModel.city) {
                    Text("Select a location").tag("")
                    ForEach(ownerFactoryViewModel.locations, id: \.self) { location in
                        Text(location).tag(location)
                    }
                }
                .pickerStyle(.menu)

                if let error = addFactoryViewModel.cityError {
                    Text(error).foregroundColor(.red).font(.caption)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                TextField("Address", text: $addFactoryViewModel.address, axis: .vertical)
                    .lineLimit(3...6)
                if let error = addFactoryViewModel.addressError {
                    Text(error).foregroundColor(.red).font(.caption)
                }
            }
        }
    }

    private var plantHeadSection: some View {
        Section("Plant Head") {
            VStack(alignment: .leading, spacing: 6) {
                Picker("Select Plant Head", selection: $addFactoryViewModel.plantHeadID) {
                    Text("Select plant head").tag(Optional<Int>(nil))
                    ForEach(addFactoryViewModel.activePlantHeads) { head in
                        Text(head.username).tag(Optional(head.id))
                    }
                }
                .pickerStyle(.menu)

            }
        }
    }
}
