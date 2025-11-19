import Foundation
import SwiftUI

@MainActor
@Observable
final class AddMerchandiseViewModel {
    var selectedImage: UIImage?
    var isLoading = false
    var name = "" {
        didSet {
            isFormValid()
        }
    }
    var requiredPoints = 0 {
        didSet {
            isFormValid()
        }
    }
    var availableQuantity = 0 {
        didSet {
            isFormValid()
        }
    }
    
    var alertMessage: String?
    var showAlert = false
    var success = false
    
    var nameError: String? = nil
    var requiredPointError: String? = nil
    var availQuantityError: String? = nil
    
    func isFormValid() -> Bool {
        var isValid = true
        
        if name.isEmpty {
            nameError = ErrorMessages.requiredField.errorDescription
            isValid = false
        }
        if requiredPoints < 1 {
            requiredPointError = ErrorMessages.requiredPoints.errorDescription
            isValid = false
        } else if availableQuantity < 1 {
            availQuantityError = ErrorMessages.availQuantity.errorDescription
            isValid = false
        }
        return isValid
    }
    
    func createMerchandise() async {
        isLoading = true
        defer { isLoading = false }
        
        let request = CreateOrUpdateMerchandiseRequest(
            name: name,
            requiredPoints: requiredPoints,
            availableQuantity: availableQuantity,
            image: ""
        )
        
        do {
            let response = try await MerchandiseService.shared.createMerchandise(request: request, image: selectedImage)
            showAlert(with: "\(response.message)")
            if response.success {
                self.success = true
            }
        } catch {
            showAlert(with: "Error: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
