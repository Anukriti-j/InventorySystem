import SwiftUI

struct PlantHeadCardView: View {
    @Bindable var viewModel: PlantHeadListViewModel
    let plantHead: PlantHead
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text(plantHead.username)
                    .font(.headline)
                
                Spacer()
                
                if plantHead.isActive == "ACTIVE" {
                    Button {
                        viewModel.prepareDelete(plantheadId: plantHead.id)
                    } label: {
                        Image(systemName: "trash")
                            .customDeleteButtonStyle()
                    }
                }
            }
            
            Text(plantHead.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Assigned Factories:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let factories = plantHead.factoryNames, !factories.isEmpty {
                    WrappingFactoryList(factories)
                } else {
                    Text("—")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            Text(plantHead.isActive)
                .customStatusStyle(status: plantHead.isActive)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(radius: 6))
        .padding(.horizontal, 12)
    }
}

struct WrappingFactoryList: View {
    let factories: [String]
    
    init(_ factories: [String]) {
        self.factories = factories
    }
    
    var body: some View {
        ForEach(factories, id: \.self) { factory in
            Text(factory)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
