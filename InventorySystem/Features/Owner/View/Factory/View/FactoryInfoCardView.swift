import Foundation
import SwiftUI

struct FactoryInfoCardView: View {
    @Bindable var viewModel: OwnerFactoryViewModel
    let title: String
    let subtitle: String?
    let infoRows: [(label: String, value: String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Button {
                        viewModel.showEditSheet = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    Button {
                        // TODO: Delete factory popup
                        viewModel.showDeletePopUp = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    
                    
                }
                
                if let subtitle {
                    Text(subtitle)
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
                let isActive = true
                Text("Status")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
                Spacer()
                Text("Active")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isActive ? .green : .red)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white))
        .shadow(color: .primaryLight.opacity(0.15), radius: 6, y: 2)
    }
}
