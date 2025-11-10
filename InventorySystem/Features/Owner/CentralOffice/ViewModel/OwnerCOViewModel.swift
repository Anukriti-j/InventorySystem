import Foundation

@MainActor
final class OwnerCOViewModel: ObservableObject {
  
    @Published private var showAlert = false
    @Published private var alertMessage: String?
    @Published var showAddSheet: Bool = false
   
    private func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}
