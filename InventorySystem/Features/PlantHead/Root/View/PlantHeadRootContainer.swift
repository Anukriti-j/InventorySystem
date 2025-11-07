import Foundation
import SwiftUI

struct PlantHeadRootContainer: View {
    @Environment(\.dismiss) var dismiss
    var factorySession = FactorySessionManager.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                FactoryPickerToolbar()
            }
            .navigationTitle("Choose factory to operate")
            .alert(factorySession.alertMessage ?? "Message",
                   isPresented: Binding(
                       get: { factorySession.showAlert },
                       set: { factorySession.showAlert = $0 }
                   )
            ) {
                Button("OK") { dismiss() }
            }
        }
    }
}


struct FactoryPickerToolbar: View {
    var factorySession = FactorySessionManager.shared
    
    var body: some View {
        Menu {
            ForEach(factorySession.factories, id: \.factoryID) { factory in
                Button {
                    factorySession.selectedFactoryID = factory.factoryID
                } label: {
                    Label(
                        factory.factoryName,
                        systemImage: factorySession.selectedFactoryID == factory.factoryID ? "checkmark" : ""
                    )
                }
            }
        } label: {
            Label(
                selectedFactoryName,
                systemImage: "building.2"
            )
        }
    }
    
    private var selectedFactoryName: String {
        if let id = factorySession.selectedFactoryID,
           let factory = factorySession.factories.first(where: { $0.factoryID == id }) {
            return factory.factoryName
        } else {
            return "Select Factory"
        }
    }
}

