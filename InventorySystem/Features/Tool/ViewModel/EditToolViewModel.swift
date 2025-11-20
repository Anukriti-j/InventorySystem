import Foundation
import SwiftUI

@Observable
@MainActor
final class EditToolViewModel: ObservableObject {
    private let tool: Tool
    
    var name = ""
    var description = ""
    var threshold = 0
    var isPerishableBool = false
    var isExpensiveBool = false
    var selectedImage: UIImage?
    var toolImageURL: String?
    
    var selectedCategoryID: Int?
    var categories: [ToolCategory] = []
    
    var isLoading = false
    var showAlert = false
    var alertMessage: String?
    var success = false
    
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
        selectedCategoryID == nil ? "Please select a category" : nil
    }
    
    var isFormValid: Bool {
        nameError == nil &&
        descriptionError == nil &&
        categoryError == nil &&
        !isLoading
    }
    
    var hasChanges: Bool {
        let isNameChanged = name.trimmingCharacters(in: .whitespacesAndNewlines) != tool.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let isDescriptionChanged = description.trimmingCharacters(in: .whitespacesAndNewlines) != tool.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let isThresholdChanged = threshold != tool.threshold
        let isPerishableChanged = isPerishableBool != (tool.isPerishable.uppercased() == "YES")
        let isExpensiveChanged = isExpensiveBool != (tool.isExpensive.uppercased() == "YES")
        let isCategoryChanged = selectedCategoryID != tool.categoryId
        let isImageChanged = selectedImage != nil
        
        return isNameChanged || isDescriptionChanged || isThresholdChanged ||
               isPerishableChanged || isExpensiveChanged || isCategoryChanged || isImageChanged
    }

    init(tool: Tool) {
        self.tool = tool
        loadToolData()
    }
    
    private func loadToolData() {
        name = tool.name
        description = tool.description
        threshold = tool.threshold
        toolImageURL = tool.imageURL
        selectedCategoryID = tool.categoryId
        
        isPerishableBool = tool.isPerishable.uppercased() == "YES"
        isExpensiveBool = tool.isExpensive.uppercased() == "YES"
    }
    
    func getCategories() async {
        do {
            let response = try await ToolService.shared.getCategories()
            categories = response.data
            
            if selectedCategoryID != nil,
               !categories.contains(where: { $0.id == selectedCategoryID }) {
                selectedCategoryID = nil
            }
        } catch {
            showAlert(message: "Failed to load categories")
        }
    }
    
    func updateTool() async {
        guard isFormValid else {
            showAlert(message: "Please fix the errors below")
            return
        }
        
        guard let categoryID = selectedCategoryID else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let request = UpdateToolRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            categoryID: categoryID,
            imageFile: "",
            isPerishable: isPerishableBool ? "YES" : "NO",
            isExpensive: isExpensiveBool ? "YES" : "NO",
            threshold: threshold
        )
        
        do {
            let response = try await ToolService.shared.updateTool(
                toolId: tool.id,
                request: request,
                image: selectedImage
            )
            success = response.success
            showAlert(message: "Tool updated successfully!")
        } catch {
            showAlert(message: "Update failed: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
