import Foundation
import SwiftUI

@MainActor
final class AddOrUpdateProductViewModel: ObservableObject {
    @Published var name = ""
    @Published var productDescription = ""
    @Published var price: String = ""
    @Published var newCategoryName: String? = nil
    @Published var selectedImage: UIImage?
    @Published var selectedCategoryID: Int? = nil
    @Published var categories: [ProductCategory] = []
    @Published var isAddingNewCategory = false
    @Published var imageURL: String = ""
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?
    @Published var success = false
//    let product: Product?
//    
//    init(product: Product? = nil){
//        self.product = product
//        self.name = product?.name ?? ""
//        self.productDescription = productDescription.description
//        self.price = product?.price
//        self.imageURL = product?.image
//        self.
//    }
//    
    var nameError: String? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Product name is required" }
        if trimmed.count < 3 { return "Name must be at least 3 characters" }
        return nil
    }
    
    var descriptionError: String? {
        let trimmed = productDescription.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Description is required" }
        if trimmed.count < 5 { return "Description must be at least 5 characters" }
        return nil
    }
    
    var categoryError: String? {
        if isAddingNewCategory {
            let trimmed = newCategoryName?.trimmingCharacters(in: .whitespaces) ?? ""
            if trimmed.isEmpty { return "Category name is required" }
            if trimmed.count < 3 { return "Category name must be at least 3 characters" }
            return nil
        } else {
            return selectedCategoryID == nil ? "Please select a category" : nil
        }
    }
    
    var priceError: String? {
        if price.isEmpty { return "Price is required" }
        guard let value = Double(price.replacingOccurrences(of: ",", with: ".")), value > 0 else {
            return "Enter a valid positive price"
        }
        return nil
    }
    
    var isFormValid: Bool {
        nameError == nil &&
        descriptionError == nil &&
        categoryError == nil &&
        priceError == nil &&
        !isLoading
    }
    
    func createOrUpdateProduct(productId: Int? = nil, mode: Mode) async {
        guard isFormValid else { return }
        isLoading = true
        defer { isLoading = false }
        
        let request = CreateOrUpdateProductRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            productDescription: productDescription.trimmingCharacters(in: .whitespaces),
            categoryID: isAddingNewCategory ? nil : selectedCategoryID,
            newCategoryName: isAddingNewCategory ? newCategoryName?.trimmingCharacters(in: .whitespaces) : nil,
            price: Double(price.replacingOccurrences(of: ",", with: ".")) ?? 0,
            imageFile: ""
        )
        
        do {
            switch mode {
            case .add:
                let response = try await ProductService.shared.createProduct(request: request, image: selectedImage)
                showAlert(message: response.message)
                success = response.success
            case .edit:
                guard let productId = productId else { return }
                let response = try await ProductService.shared.updateProduct(request: request, image: selectedImage, productId: productId)
                showAlert(message: response.message)
                success = response.success
            }
            resetForm()
        } catch {
            showAlert(message: "Failed: \(error.localizedDescription)")
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
