import Foundation
import SwiftUI

@MainActor
final class EditToolViewModel: ObservableObject {
    private let tool: Tool
    
    @Published var name = ""
    @Published var description = ""
    @Published var threshold = 0
    @Published var availableQuantity = 0
    @Published var isPerishableBool = false
    @Published var isExpensiveBool = false
    @Published var selectedImage: UIImage?
    @Published var toolImageURL: String?
    
    @Published var selectedCategoryID: Int?
    @Published var categories: [ToolCategory] = []
    
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage: String?
    @Published var success = false
    
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedCategoryID != nil
    }
    
    init(tool: Tool) {
        self.tool = tool
        loadToolData()
    }
    
    private func loadToolData() {
        name = tool.name
        description = tool.description
        threshold = tool.threshold
        availableQuantity = tool.availableQuantity
        toolImageURL = tool.imageURL
        selectedCategoryID = tool.categoryId
        
        isPerishableBool = tool.isPerishable.uppercased().contains("YES") ||
        tool.isPerishable.uppercased().contains("PERISHABLE")
        
        isExpensiveBool = tool.isExpensive.uppercased().contains("YES") ||
        tool.isExpensive.uppercased().contains("EXPENSIVE")
    }
    
    func getCategories() async {
        do {
            let response = try await ToolService.shared.getCategories()
            categories = response.data
            // Keep current selection if still exists
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
            showAlert(message: "Please fill name and select a category")
            return
        }
        
        guard let categoryID = selectedCategoryID else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let request = UpdateToolRequest(
            name: name,
            description: description,
            categoryID: categoryID,
            imageFile: "", // handled via multipart
            isPerishable: isPerishableBool ? "YES" : "NO",
            isExpensive: isExpensiveBool ? "Yes" : "NO",
            threshold: threshold,
            availableQuantity: availableQuantity
        )
        
        do {
            let response = try await ToolService.shared.updateTool(
                toolId: tool.id,
                request: request,
                image: selectedImage
            )
            success = true
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
