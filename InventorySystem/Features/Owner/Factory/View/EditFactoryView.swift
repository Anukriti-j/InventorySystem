import SwiftUI

struct EditFactoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var city: String
    @State private var address: String
    @State private var plantHeadID: Int?
    
    let factory: FactoryResponse
    var plantHeads: [(id: Int, name: String)] = [
        (1, "John Doe"),
        (2, "Amit Sharma"),
        (3, "Priya Nair"),
        (4, "David Wilson")
    ]
    
    var onUpdate: ((FactoryResponse) -> Void)?     // Callback to parent
    
    init(factory: FactoryResponse,
         plantHeads: [(id: Int, name: String)],
         onUpdate: ((FactoryResponse) -> Void)? = nil)
    {
        self.factory = factory
        self.plantHeads = plantHeads
        self.onUpdate = onUpdate
        
        _name = State(initialValue: factory.name)
        _city = State(initialValue: factory.city)
        _address = State(initialValue: factory.address)
        _plantHeadID = State(initialValue: factory.plantHeadID)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Factory Details")) {
                    TextField("Factory Name", text: $name)
                    TextField("City", text: $city)
                    TextField("Address", text: $address, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section(header: Text("Plant Head")) {
                    Picker("Select Plant Head", selection: $plantHeadID) {
                        ForEach(plantHeads, id: \.id) { head in
                            Text(head.name).tag(head.id as Int?)
                        }
                    }
                }
            }
            .navigationTitle("Edit Factory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Update") { updateFactory() }
                        .disabled(!isFormValid || !hasChanges)
                        .bold()
                }
            }
        }
    }
}

extension EditFactoryView {
    
    private var isFormValid: Bool {
        !name.isEmpty && !city.isEmpty && !address.isEmpty && plantHeadID != nil
    }
    
    private var hasChanges: Bool {
        name != factory.name ||
        city != factory.city ||
        address != factory.address ||
        plantHeadID != factory.plantHeadID
    }
    
    private func updateFactory() {
        guard let plantHeadID else { return }
        
        let updated = FactoryResponse(
            id: factory.id,
            name: name,
            city: city,
            address: address,
            plantHeadID: plantHeadID
        )
        
        onUpdate?(updated)
        dismiss()
    }
    
}
#Preview {
    EditFactoryView(
        factory: FactoryResponse(id: 11, name: "GreenTech Plant", city: "Pune", address: "Magarpatta, Pune", plantHeadID: 2),
        plantHeads: [
            (1, "John Doe"),
            (2, "Amit Sharma"),
            (3, "Priya Nair"),
            (4, "David Wilson")
        ],
        onUpdate: { updated in
            print("Updated:", updated)
        }
    )
}
