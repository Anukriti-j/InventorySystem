import Foundation

@Observable
final class AddFactoryViewModel {
    var name: String = ""
    var city: String = ""
    var address: String = ""
    var plantHeadID: Int?
    var response: CreateFactoryResponse?
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
   
    //MARK: Change planthead id, get planthead
    func createFactory() async {
        do {
            response = try await OwnerFactoryService.shared.createFactory(request: CreateFactoryRequest(name: name, city: city, address: address, plantHeadID: 1))
            alertMessage = response?.message
            if let success = response?.success {
                self.success = true
            }
            print(response?.message)
            showAlert = true
        } catch {
            print(error)
        }
        name = ""
        city = ""
        address = ""
    }
}
