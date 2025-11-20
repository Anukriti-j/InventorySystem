import Foundation
import SwiftUI

@MainActor
final class AddToolViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var threshold = 5
    @Published var isPerishableBool = false
    @Published var isExpensiveBool = false
    @Published var selectedImage: UIImage?
    @Published var selectedCategoryID: Int?
    @Published var categories: [ToolCategory] = []
    @Published var isAddingNewCategory = false
    @Published var newCategoryName: String?
    
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var success = false
    
    var nameError: String? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Tool name is required" }
        if trimmed.count < 3 { return "Name must be at least 3 characters" }
        return nil
    }
    
    var descriptionError: String? {
        let trimmed = description.trimmingCharacters(in: .whitespaces)
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
    
    var isFormValid: Bool {
        nameError == nil &&
        descriptionError == nil &&
        categoryError == nil &&
        !isLoading
    }
    
    func getCategories() async {
        do {
            let response = try await ToolService.shared.getCategories()
            categories = response.data
        } catch {
            showAlert(message: "Failed to load categories")
        }
    }
    
    func createTool() async {
        guard isFormValid else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let request = CreateToolRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            categoryID: isAddingNewCategory ? nil : selectedCategoryID,
            newCategoryName: isAddingNewCategory ? newCategoryName?.trimmingCharacters(in: .whitespaces) : nil,
            imageFile: "",
            isPerishable: isPerishableBool ? "YES" : "NO",
            isExpensive: isExpensiveBool ? "YES" : "NO",
            threshold: threshold
        )
        
        do {
            let response = try await ToolService.shared.createTool(request: request, image: selectedImage)
            success = true
            showAlert(message: "Tool created successfully!")
            resetForm()
        } catch {
            showAlert(message: "Failed: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func resetForm() {
        name = ""
        description = ""
        threshold = 5
        isPerishableBool = false
        isExpensiveBool = false
        selectedImage = nil
        selectedCategoryID = nil
        isAddingNewCategory = false
        newCategoryName = nil
    }
}
