import Foundation

@MainActor
class AddPlantHeadViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var email: String = ""
    @Published var success: Bool = false
    
    @Published var createPHResponse: CreatePHResponse?
    @Published var unassignedFactories: [GetUnassignedFactoryData] = []
    @Published var getFactoryResponse: GetUnassignedFactory?
    
    var nameError: String?
    var emailError: String?
    
    @Published var alertMessage: String?
    @Published var showAlert: Bool = false
    
    // MARK: - Validation
    var isFormValid: Bool {
        var isValid = true
        nameError = nil
        emailError = nil
        
        if name.isEmpty {
            nameError = ErrorMessages.requiredField.errorDescription
            isValid = false
        }
        if email.isEmpty {
            emailError = ErrorMessages.requiredField.errorDescription
            isValid = false
        } else if !email.isEmail {
            emailError = ErrorMessages.invalidEmail.errorDescription
            isValid = false
        }
        return isValid
    }
    
    deinit {
        print("#### viewmodel deinit")
    }

    func getUnassignedFactories() async {
        do {
            let response = try await OwnerPHService.shared.getUnassignedFactory()
            getFactoryResponse = response
            if response.success {
                unassignedFactories = response.data
            } else {
                unassignedFactories = [GetUnassignedFactoryData(factoryID: 0, factoryName: "All factories assigned")]
            }
        } catch {
            alertMessage = "Failed to fetch factories: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    func createPlantHead(factoryID: Int) async {
        do {
            createPHResponse = try await OwnerPHService.shared.createPlantHead(
                request: CreatePHRequest(
                    username: name,
                    email: email,
                    factoryID: factoryID
                )
            )
            success = createPHResponse?.success ?? false // check for this value false
            alertMessage = createPHResponse?.message ?? "Unknown response"
            showAlert = true
        } catch {
            success = false
            alertMessage = "An error occurred: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
