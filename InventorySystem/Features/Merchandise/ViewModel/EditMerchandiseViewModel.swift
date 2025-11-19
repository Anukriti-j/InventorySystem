import Foundation
import SwiftUI

@MainActor
@Observable
final class EditMerchandiseViewModel {
    private let merchandise: Merchandise
    
    var name = ""
    var requiredPoints = 0
    var availableQuantity = 0
    var selectedImage: UIImage?
    var merchandiseImageURL: String?
    
    var isLoading = false
    var showAlert = false
    var alertMessage: String?
    var success = false
    
    init(merchandise: Merchandise, name: String = "", requiredPoints: Int = 0, availableQuantity: Int = 0, selectedImage: UIImage? = nil, isLoading: Bool = false, showAlert: Bool = false, alertMessage: String? = nil, success: Bool = false) {
        self.merchandise = merchandise
        self.name = name
        self.requiredPoints = requiredPoints
        self.availableQuantity = availableQuantity
        self.selectedImage = selectedImage
        self.isLoading = isLoading
        self.showAlert = showAlert
        self.alertMessage = alertMessage
        self.success = success
        loadMerchandiseData()
    }
    
    func hasChanges() -> Bool {
        if !(merchandise.name == name) || !(merchandise.requiredPoints == requiredPoints) || !(merchandise.availableQuantity == availableQuantity) {
            return false
        } else if let changedImage = selectedImage {
            return true
        }
        return true
    }
    
    private func loadMerchandiseData() {
        name = merchandise.name
        requiredPoints = merchandise.requiredPoints
        availableQuantity = merchandise.availableQuantity
        merchandiseImageURL = merchandise.imageURL
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    func updateMerchandise() async {
        isLoading = true
        defer { isLoading = false }
        
        let request = CreateOrUpdateMerchandiseRequest(
            name: name,
            requiredPoints: requiredPoints,
            availableQuantity: availableQuantity,
            image: merchandiseImageURL ?? ""
        )
        
        do {
            let response = try await MerchandiseService.shared.updateMerchandise(request: request, image: selectedImage)
            if response.success {
                success = true
            }
            showAlert(message: "Merchandise updated successfully!")
        } catch {
            showAlert(message: "Update failed: \(error.localizedDescription)")
        }
    }
}
