import Foundation
import SwiftUI

@MainActor
@Observable
final class AddWorkerViewModel {
    
    var factoryID: Int = 0
    var name: String = ""
    var email: String = ""
    var bayID: Int = 0
    var bays: [Bay] = []
    var selectedImage: UIImage?
    
    var isLoadingWorker = false
    var showAlert = false
    var alertMessage = ""
    var success = false
    
    init(factoryId: Int?) {
        self.factoryID = factoryId ?? 0
    }
    
    func addWorker() async {
        guard factoryID != 0 else {
            showAlert(with: "Please select a factory")
            return
        }
        guard bayID != 0 else {
            showAlert(with: "Please select a bay")
            return
        }
        
        isLoadingWorker = true
        defer { isLoadingWorker = false }
        
        let request = CreateWorkerRequest(
            factoryID: factoryID,
            name: name,
            email: email,
            bayID: bayID,
            image: ""
        )
        
        do {
            let response = try await WorkerService.shared.createWorker(request: request, image: selectedImage)
            success = response.success
            showAlert(with: response.message)
        } catch {
            showAlert(with: "Cannot add worker: \(error.localizedDescription)")
        }
    }
    
    func getWorkersBay() async {
        guard factoryID != 0 else {
            bays = []
            return
        }
        
        do {
            let response = try await WorkerService.shared.getWorkersBay(factoryId: factoryID)
            if let data = response.data {
                bays = data
            }
            success = response.success
        } catch {
            bays = []
            showAlert(with: "Cannot fetch bays: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
