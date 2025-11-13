import SwiftUI

@MainActor
final class AddProductViewModel: ObservableObject {
    @Published var name = ""
    @Published var productDescription = ""
    @Published var price = ""
    @Published var newCategoryName: String? = nil
    @Published var selectedImage: UIImage?
    @Published var selectedCategoryID: Int? = nil
    @Published var categories: [ProductCategory] = []
    @Published var isAddingNewCategory = false

    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?
    @Published var success = false

    // MARK: - Create Product
    func createProduct() async {
        isLoading = true
        defer { isLoading = false }

        guard let priceDouble = Double(price), priceDouble > 0 else {
            showAlert(message: "Please enter a valid price")
            return
        }

        let request = CreateProductRequest(
            name: name,
            productDescription: productDescription,
            categoryID: isAddingNewCategory ? nil : selectedCategoryID,
            newCategoryName: isAddingNewCategory ? newCategoryName : nil,
            price: priceDouble,
            imageFile: "" // handled in service
        )

        do {
            let response = try await OwnerProductService.shared.createProduct(request: request, image: selectedImage)
            showAlert(message: "Product created: \(response.message)")
            success = true
            resetForm()
        } catch {
            showAlert(message: "Error: \(error.localizedDescription)")
            success = false
        }
    }

    // MARK: - Load Categories
    func getProductCategories() async {
        do {
            let response = try await OwnerProductService.shared.getProductCategories()
            categories = response.data
        } catch {
            showAlert(message: "Failed to load categories")
        }
    }

    // MARK: - Reset Form
    private func resetForm() {
        name = ""
        productDescription = ""
        price = ""
        newCategoryName = nil
        selectedImage = nil
        selectedCategoryID = nil
        isAddingNewCategory = false
    }

    // MARK: - Alert
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
