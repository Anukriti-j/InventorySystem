import Foundation

@Observable
final class OwnerFactoryViewModel {
    var searchText: String = ""
    var showfilterSheet: Bool = false
    var showSortSheet: Bool = false
    var selectedSort: String? = nil
    var showFactoryDetail: Bool = false
    var showAddSheet: Bool = false
    var showEditSheet: Bool = false
    var showDeletePopUp: Bool = false
    
    let plantHeads: [(id: Int, name: String)] = [
        (1, "John Doe"),
        (2, "Amit Sharma"),
        (3, "Priya Nair"),
        (4, "David Wilson")
    ]
}
