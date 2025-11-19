import Foundation

@Observable
final class AddFactoryViewModel {
    var name: String = ""
    var city: String = ""
    var address: String = ""
    var plantHeadID: Int?
    
    var createFactoryResponse: CreateFactoryResponse?
    var plantHeadsList: [PlantHeadData] = []
    
    var showAlert: Bool = false
    var alertMessage: String?
    var success: Bool = false
    var isFetchingPlantHeads = false
    var isSavingFactory = false
    
    var activePlantHeads: [PlantHeadData] {
        plantHeadsList.filter { $0.isActive == "ACTIVE" }
    }
    
    var isFormValid: Bool {
        !name.isEmpty && !city.isEmpty && !address.isEmpty
    }
    
    func getAllPlantHeads() async {
        isFetchingPlantHeads = true
        print("fetching plant heads")
        defer { isFetchingPlantHeads = false }
        do {
            let response = try await PlantHeadService.shared.getAllPlantHeads()
            print(response)
            if response.success, !response.data.isEmpty {
                plantHeadsList = response.data
            } else {
                plantHeadsList = [PlantHeadData(id: 0, username: "No Plant Head Found", isActive: "No")]
            }
        } catch {
            showAlert(with: "Failed to fetch plant heads: \(error.localizedDescription)")
        }
    }
    
    func createFactory() async {
        isSavingFactory = true
        defer { isSavingFactory = false }
        let request = CreateFactoryRequest(
            name: name,
            city: city,
            address: address,
            plantHeadID: plantHeadID ?? 0
        )
        
        do {
            let response = try await FactoryService.shared.createFactory(request: request)
            alertMessage = createFactoryResponse?.message
            success = response.success
            showAlert(with: response.message)
            
            if success {
                resetForm()
            }
        } catch {
            showAlert(with: "Failed to create factory: \(error.localizedDescription)")
        }
    }
    
    private func resetForm() {
        name = ""
        city = ""
        address = ""
        plantHeadID = nil
    }
    
    private func showAlert(with message: String?) {
        alertMessage = message
        showAlert = true
    }
}
