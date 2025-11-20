import Foundation

@Observable
final class AddFactoryViewModel {
    var name = ""
    var city = ""
    var address = ""
    var plantHeadID: Int? = nil

    var plantHeadsList: [PlantHeadData] = []
    var isFetchingPlantHeads = false
    var isSavingFactory = false
    var showAlert = false
    var alertMessage = ""
    var success = false

    var activePlantHeads: [PlantHeadData] {
        plantHeadsList.filter { $0.isActive.uppercased() == "ACTIVE" }
    }

    var nameError: String? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Factory name is required" }
        if trimmed.count < 3 { return "Name must be at least 3 characters" }
        return nil
    }

    var cityError: String? {
        let trimmed = city.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "City is required" }
        if trimmed.count < 3 { return "City must be at least 3 characters" }
        return nil
    }

    var addressError: String? {
        let trimmed = address.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Address is required" }
        if trimmed.count < 5 { return "Address must be at least 5 characters" }
        return nil
    }

    var isFormValid: Bool {
        nameError == nil &&
        cityError == nil &&
        addressError == nil &&
        !isSavingFactory
    }

    func getAllPlantHeads() async {
        isFetchingPlantHeads = true
        defer { isFetchingPlantHeads = false }

        do {
            let response = try await PlantHeadService.shared.getAllPlantHeads()
            plantHeadsList = response.success ? response.data : []
            if plantHeadsList.isEmpty {
                plantHeadsList = [PlantHeadData(id: -1, username: "No plant heads available", isActive: "INACTIVE")]
            }
        } catch {
            showAlert(message: "Failed to load plant heads")
        }
    }

    func createFactory() async {
        guard isFormValid else { return }

        isSavingFactory = true
        defer { isSavingFactory = false }

        let request = CreateFactoryRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            city: city.trimmingCharacters(in: .whitespaces),
            address: address.trimmingCharacters(in: .whitespaces),
            plantHeadId: plantHeadID ?? nil
        )

        do {
            let response = try await FactoryService.shared.createFactory(request: request)
            success = response.success
            showAlert(message: response.success ? "Factory created successfully!" : response.message)
            if success { resetForm() }
        } catch {
            showAlert(message: "Failed to create factory: \(error.localizedDescription)")
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }

    private func resetForm() {
        name = ""
        city = ""
        address = ""
        plantHeadID = nil
    }
}
