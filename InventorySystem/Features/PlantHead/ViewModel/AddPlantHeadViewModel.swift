import Foundation

@MainActor
class AddPlantHeadViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var success: Bool = false
    @Published var isLoadingFactories = false
    @Published var isCreating = false
    
    @Published var createPHResponse: CreatePHResponse?
    @Published var unassignedFactories: [GetUnassignedFactoryData] = []
    @Published var getFactoryResponse: GetUnassignedFactory?
    
    var nameError: String?
    var emailError: String?
    
    @Published var alertMessage: String?
    @Published var showAlert: Bool = false
    
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
    
    func getUnassignedFactories() async {
        isLoadingFactories = true
        defer {
            isLoadingFactories = false
        }
        do {
            let response = try await PlantHeadService.shared.getUnassignedFactory()
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
    
    func createPlantHead(factoryID: Int? = nil) async {
        isCreating = true
        defer {
            isCreating = false
        }
        do {
            let response = try await PlantHeadService.shared.createPlantHead(
                request: CreatePlantHeadRequest(
                    username: name,
                    email: email,
                    factoryId: factoryID
                )
            )
            success = response.success
            showAlert(with: response.message)
        } catch {
            showAlert(with: "An error occurred: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
