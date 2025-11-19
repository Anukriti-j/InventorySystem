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
    
    var nameError: String? {
        name.isEmpty ? "Product name cannot be empty" : nil
    }
    
    var descriptionError: String? {
        productDescription.isEmpty ? "Description cannot be empty" : nil
    }
    
    var categoryError: String? {
        if isAddingNewCategory {
            return (newCategoryName?.isEmpty ?? true) ? "Enter new category name" : nil
        } else {
            return selectedCategoryID == nil ? "Select a category" : nil
        }
    }
    
    var priceError: String? {
        if price.isEmpty { return "Price cannot be empty" }
        guard let value = Double(price), value > 0 else {
            return "Price must be a positive number"
        }
        return nil
    }
    
    var isFormValid: Bool {
        return nameError == nil &&
        descriptionError == nil &&
        categoryError == nil &&
        priceError == nil &&
        !isLoading
    }
    
    func createProduct() async {
        guard isFormValid else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let request = CreateProductRequest(
            name: name,
            productDescription: productDescription,
            categoryID: isAddingNewCategory ? nil : selectedCategoryID,
            newCategoryName: isAddingNewCategory ? newCategoryName : nil,
            price: Double(price) ?? 0,
            imageFile: ""
        )
        
        do {
            let response = try await ProductService.shared.createProduct(request: request, image: selectedImage)
            showAlert(message: "Product created: \(response.message)")
            success = true
            resetForm()
        } catch {
            showAlert(message: "Error: \(error.localizedDescription)")
            success = false
        }
    }
    
    func getProductCategories() async {
        do {
            let response = try await ProductService.shared.getProductCategories()
            categories = response.data
        } catch {
            showAlert(message: "Failed to load categories")
        }
    }
    
    private func resetForm() {
        name = ""
        productDescription = ""
        price = ""
        newCategoryName = nil
        selectedImage = nil
        selectedCategoryID = nil
        isAddingNewCategory = false
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
