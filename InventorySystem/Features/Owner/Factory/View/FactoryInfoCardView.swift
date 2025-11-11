import Foundation
import SwiftUI

struct FactoryInfoCardView: View {
    @Bindable var viewModel: OwnerFactoryViewModel
    let factoryID: Int
    let factoryName: String
    let location: String?
    let status: String
    let infoRows: [FactoryInfoRow]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(factoryName)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Button {
                        viewModel.showEditSheet = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    Button {
                        viewModel.prepareDelete(factoryId: factoryID)
                        viewModel.showDeletePopUp = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    
                    
                }
                
                if let location {
                    Text(location)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            
            VStack(spacing: 6) {
                ForEach(infoRows, id: \.label) { row in
                    HStack {
                        Text(row.label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(row.value)
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
            }
            HStack {
                // MARK: fetch status from API
                Text("Status")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
                Spacer()
                Text(status)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(status == "ACTIVE" ? .green : .red)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white))
        .shadow(color: .primaryLight.opacity(0.15), radius: 6, y: 2)
    }
}
