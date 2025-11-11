//import Foundation
//import SwiftUI
//
//@MainActor
//final class EditFactoryViewModel: ObservableObject {
//    // MARK: - Input fields
//    @Published var name: String
//    @Published var city: String
//    @Published var address: String
//    @Published var plantHeadID: Int?
//
//    // MARK: - UI state
//    @Published var isLoading = false
//    @Published var showAlert = false
//    @Published var alertMessage: String?
//    @Published var updateSuccess = false
//    @Published var plantHeadList: [GetAllPlantHeadData]
//    @Published var isFetchingPlantHead = false
//    
//    @Published var activePlantHeads: [GetAllPlantHeadData] {
//        plantHeadsList.filter { $0.isActive == "YES" }
//    }
//
//    // MARK: - Source data
//    private let originalFactory: FactoryResponse
//
//    // MARK: - Init
//    init(factory: FactoryResponse) {
//        self.originalFactory = factory
//        self.name = factory.name
//        self.city = factory.city
//        self.address = factory.address
//        self.plantHeadID = factory.plantHeadID
//    }
//
//    // MARK: - Computed validation properties
//    var isFormValid: Bool {
//        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
//        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
//        !address.trimmingCharacters(in: .whitespaces).isEmpty &&
//        plantHeadID != nil
//    }
//
//    var hasChanges: Bool {
//        name != originalFactory.name ||
//        city != originalFactory.city ||
//        address != originalFactory.address ||
//        plantHeadID != originalFactory.plantHeadID
//    }
//    
//    func getAllPlantHeads() async {
//        isFetchingPlantHeads = true
//        defer { isFetchingPlantHeads = false }
//        do {
//            let response = try await OwnerFactoryService.shared.getAllPlantHeads()
//            if response.success, !response.data.isEmpty {
//                plantHeadsList = response.data
//            } else {
//                plantHeadsList = [GetAllPlantHeadData(id: 0, username: "No Plant Head Found", isActive: "No")]
//            }
//        } catch {
//            showAlert(with: "Failed to fetch plant heads: \(error.localizedDescription)")
//        }
//    }
//
//    // MARK: - Update factory
//    func updateFactory() async {
//        guard isFormValid, let plantHeadID else {
//            alertMessage = "Please fill all required fields."
//            showAlert = true
//            return
//        }
//
//        isLoading = true
//        defer { isLoading = false }
//
//        let updatedFactory = UpdateFactoryRequest(
//            id: originalFactory.id,
//            name: name,
//            city: city,
//            address: address,
//            plantHeadID: plantHeadID
//        )
//
//        do {
//            let response = try await OwnerFactoryService.shared.updateFactory(request: updatedFactory)
//            updateSuccess = response.success
//            showAlert(with: response.message)
//        } catch {
//            showAlert(with: "Failed to update factory: \(error.localizedDescription)")
//        }
//    }
//    
//    private func showAlert(with message: String) {
//        alertMessage = message
//        showAlert = true
//    }
//
//    // MARK: - Convert to updated model for local refresh
//    // Check if factory response is the actual model to update
//    func toUpdatedFactory() -> FactoryResponse {
//        FactoryResponse(
//            id: originalFactory.id,
//            name: name,
//            city: city,
//            address: address,
//            plantHeadID: plantHeadID ?? originalFactory.plantHeadID
//        )
//    }
//}
