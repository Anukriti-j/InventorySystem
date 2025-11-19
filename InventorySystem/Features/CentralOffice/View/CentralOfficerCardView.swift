import SwiftUI

struct CentralOfficerCardView: View {
    @Bindable var viewModel: CentralOfficerViewModel
    let officer: CentralOfficer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(officer.username)
                    .font(.headline)
                Spacer()
                
                Button {
                    viewModel.prepareDelete(centralOfficerID: officer.id)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .allowsHitTesting(true)
            }
            
            Text(officer.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(officer.isActive)
                .customStatusStyle(status: officer.isActive)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(radius: 4)
        )
        .contentShape(Rectangle())
    }
}
