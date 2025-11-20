import Foundation
import SwiftUI

@MainActor
@Observable
final class EditMerchandiseViewModel {
    private let merchandise: Merchandise
    
    var originalName: String
    var originalRequiredPoints: Int
    var originalAvailableQuantity: Int
    
    var name: String { didSet { validateName() } }
    var requiredPoints: Int { didSet { validatePoints() } }
    var availableQuantity: Int { didSet { validateQuantity() } }
    var selectedImage: UIImage?
    var merchandiseImageURL: String?
    
    var isLoading = false
    var showAlert = false
    var alertMessage: String?
    var success = false
    
    var nameError: String? = nil
    var requiredPointError: String? = nil
    var availQuantityError: String? = nil
    
    init(merchandise: Merchandise) {
        self.merchandise = merchandise
        self.originalName = merchandise.name
        self.originalRequiredPoints = merchandise.requiredPoints
        self.originalAvailableQuantity = merchandise.availableQuantity
        
        self.name = merchandise.name
        self.requiredPoints = merchandise.requiredPoints
        self.availableQuantity = merchandise.availableQuantity
        self.merchandiseImageURL = merchandise.imageURL
    }
    
    func validateName() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        nameError = trimmed.isEmpty ? "Name is required" : (trimmed.count < 3 ? "Name must be at least 3 characters" : nil)
    }
    
    func validatePoints() {
        requiredPointError = requiredPoints < 1 ? "Required points must be at least 1" : nil
    }
    
    func validateQuantity() {
        availQuantityError = availableQuantity < 1 ? "Available quantity must be at least 1" : nil
    }
    
    var isFormValid: Bool {
        nameError == nil && requiredPointError == nil && availQuantityError == nil
    }
    
    func hasChanges() -> Bool {
        name != originalName || requiredPoints != originalRequiredPoints || availableQuantity != originalAvailableQuantity || selectedImage != nil
    }
    
    func updateMerchandise() async {
        guard isFormValid else {
            showAlert(message: "Please fix errors")
            return
        }
        isLoading = true
        defer { isLoading = false }
        
        let request = CreateOrUpdateMerchandiseRequest(
            name: name,
            requiredPoints: requiredPoints,
            availableQuantity: availableQuantity,
            image: merchandiseImageURL ?? ""
        )
        do {
            let response = try await MerchandiseService.shared.updateMerchandise(request: request, image: selectedImage, merchandiseId: merchandise.id)
            success = response.success
            showAlert(message: "Merchandise updated successfully!")
        } catch {
            showAlert(message: "Update failed: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
