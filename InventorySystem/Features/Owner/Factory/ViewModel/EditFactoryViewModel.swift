import Foundation
import SwiftUI

@MainActor
final class EditFactoryViewModel: ObservableObject {
    @Published var factoryName: String
    @Published var location: String
    @Published var address: String
    @Published var plantHeadID: Int?
    @Published var plantHeadName: String

    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?
    @Published var updateSuccess = false
    @Published var plantHeadList: [PlantHeadData] = []
    @Published var isFetchingPlantHead = false
    
    var activePlantHeads: [PlantHeadData] {
        plantHeadList.filter { $0.isActive == "ACTIVE" }
    }

    private let originalFactory: Factory

    init(factory: Factory) {
        self.originalFactory = factory
        self.factoryName = factory.factoryName
        self.location = factory.location
        self.address = factory.address
        self.plantHeadName = factory.plantHeadName
        self.plantHeadID = factory.plantHeadId
    }

    var isFormValid: Bool {
        !factoryName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty &&
        plantHeadID != nil
    }

    var hasChanges: Bool {
        factoryName != originalFactory.factoryName ||
        location != originalFactory.location ||
        address != originalFactory.address ||
        plantHeadID != originalFactory.plantHeadId
    }
    
    func getAllPlantHeads() async {
        isFetchingPlantHead = true
        defer { isFetchingPlantHead = false }
        do {
            let response = try await OwnerFactoryService.shared.getAllPlantHeads()
            if response.success, !response.data.isEmpty {
                plantHeadList = response.data
            } else {
                plantHeadList = [PlantHeadData(id: 0, username: "No Plant Head Found", isActive: "No")]
            }
            print("get all ph:\(response)")
        } catch {
            showAlert(with: "Failed to fetch plant heads: \(error.localizedDescription)")
        }
    }

    func updateFactory() async {
        guard isFormValid else {
            alertMessage = "Please fill all required fields."
            showAlert = true
            return
        }

        isLoading = true
        defer { isLoading = false }
        
        guard let plantHeadID = plantHeadID else {
            showAlert(with: "Please select a Plant Head before updating.")
            return
        }

        let updatedFactory = UpdateFactoryRequest(
            id: originalFactory.id,
            name: factoryName,
            city: location,
            address: address,
            plantHeadID: plantHeadID
        )

        do {
            let response = try await OwnerFactoryService.shared.updateFactory(request: updatedFactory)
            updateSuccess = response.success
            showAlert(with: response.message)
        } catch {
            showAlert(with: "Failed to update factory: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
//
//    func toUpdatedFactory() -> Factory {
//        Factory(
//            id: originalFactory.id,
//            factoryName: factoryName,
//            location: location,
//            plantHeadName: plantHeadName, plantHeadId: plantHeadID,
//            totalProducts: originalFactory.totalProducts,
//            totalTools: originalFactory.totalTools,
//            totalWorkers: originalFactory.totalWorkers,
//            status: originalFactory.status, address: address,
//            chiefSupervisorName: originalFactory.chiefSupervisorName
//        )
//    }
}
