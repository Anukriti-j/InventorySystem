import Foundation
import SwiftUI

struct PlantHeadRootContainer: View {
    @Environment(SessionManager.self) var sessionManager
    @Environment(\.dismiss) var dismiss
    var factorySession = FactorySessionManager.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                if factorySession.isLoading {
                    ProgressView("Loading Factories...")
                        .padding()
                }
                else if factorySession.factories.isEmpty {
                    Text("No factories assigned yet.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding()
                }
                else {
                    FactoryPickerToolbar()
                }
            }
            .navigationTitle("Choose Factory to Operate")
            .alert(factorySession.alertMessage ?? "Message",
                   isPresented: Binding(
                    get: { factorySession.showAlert },
                    set: { factorySession.showAlert = $0 }
                   )
            ) {
                Button("OK") { dismiss() }
            }
        }
        .onAppear {
            Task {
                if let plantHeadID = sessionManager.user?.id {
                    await factorySession
                        .loadPHFactories(plantHeadID: plantHeadID)
                }
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
            .font(.headline)
            .padding()
        }
    }
    
    private var selectedFactoryName: String {
        if let id = factorySession.selectedFactoryID,
           let factory = factorySession.factories.first(
            where: { $0.factoryID == id
            }) {
            return factory.factoryName
        } else {
            return "Select Factory"
        }
    }
}
