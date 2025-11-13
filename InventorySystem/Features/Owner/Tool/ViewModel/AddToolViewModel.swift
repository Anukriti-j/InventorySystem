import SwiftUI

@MainActor
final class AddToolViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var newCategoryName: String? = nil
    @Published var isPerishable: String = "NO"
    @Published var isExpensive: String = "NO"
    @Published var threshold = 0
    @Published var selectedImage: UIImage?
    @Published var selectedCategoryID: Int? = nil
    @Published var categories: [ToolCategory] = []

    @Published var isAddingNewCategory = false

    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false

    func createTool() async {
        isLoading = true
        defer { isLoading = false }

        let categoryIDToSend = isAddingNewCategory ? nil : selectedCategoryID
        let newCategoryToSend = isAddingNewCategory ? newCategoryName : ""

        let request = CreateToolRequest(
            name: name,
            description: description,
            categoryID: categoryIDToSend ?? nil,
            newCategoryName: newCategoryToSend ?? nil,
            imageFile: "",
            isPerishable: isPerishable,
            isExpensive: isExpensive,
            threshold: threshold
        )

        do {
            let response = try await OwnerToolService.shared.createTool(request: request, image: selectedImage)
            showAlert(with: "Tool created: \(response.message)")
            print(response)
        } catch {
            showAlert(with: "Error: \(error.localizedDescription)")
        }
    }

    func getCategories() async {
        do {
            let response = try await OwnerToolService.shared.getCategories()
            categories = response.data // adjust based on your API response model
        } catch {
            showAlert(with: "Error fetching categories: \(error.localizedDescription)")
        }
    }

    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
