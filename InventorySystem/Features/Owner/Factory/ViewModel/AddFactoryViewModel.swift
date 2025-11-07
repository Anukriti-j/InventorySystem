import Foundation

@Observable
final class AddFactoryViewModel {
    var name: String = ""
    var city: String = ""
    var address: String = ""
    var plantHeadID: Int?
    var createFactoryResponse: CreateFactoryResponse?
    var getAllPHResponse: GetAllPlantHeads?
    var plantHeadsList: [GetAllPlantHeadData]?
    var showAlert: Bool = false
    var alertMessage: String?
    var success: Bool = false
    
    
    // Mock data – replace with API values
    let plantHeads: [(id: Int, name: String)] = [
        (1, "John Doe"),
        (2, "Amit Sharma"),
        (3, "Priya Nair"),
        (4, "David Wilson")
    ]
    
    var isFormValid: Bool {
        !name.isEmpty && !city.isEmpty && !address.isEmpty
    }
    
    func getAllPlantHeads() async throws {
//        do {
//            getAllPHResponse = try await OwnerFactoryService.shared.getAllPlantHeads()
//            if getAllPHResponse.success {
//                plantHeadsList = getAllPHResponse.data
//            } else {
//                plantHeadsList = [GetAllPlantHeadData(plantheadID: 0, username: "No plant Head Found", isActive: "No")]
//            }
//        } catch {
//            alertMessage = "Failed to fetch factories: \(error.localizedDescription)"
//            showAlert = true
//        }
    }
   
    //MARK: Change planthead id, get planthead
    func createFactory() async {
        do {
            createFactoryResponse = try await OwnerFactoryService.shared.createFactory(request: CreateFactoryRequest(name: name, city: city, address: address, plantHeadID: 1))
            alertMessage = createFactoryResponse?.message
            if let success = createFactoryResponse?.success {
                self.success = true
            }
            print(createFactoryResponse?.message)
            showAlert = true
        } catch {
            print(error)
        }
        name = ""
        city = ""
        address = ""
    }
}
