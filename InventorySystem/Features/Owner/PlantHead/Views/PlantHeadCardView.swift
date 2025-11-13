import SwiftUI

struct PlantHeadCardView: View {
    @Bindable var viewModel: OwnerPlantHeadViewModel
    let plantHead: PlantHead
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(plantHead.username)
                    .font(.headline)
                Spacer()
                
                Button {
                    viewModel.prepareDelete(plantheadId: plantHead.id)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .allowsHitTesting(true)
            }
            
            Text(plantHead.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(plantHead.isActive)
                .customStatusStyle(status: plantHead.isActive)
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
