import Foundation
import SwiftUI

struct FactoryInfoCardView: View {
    @Bindable var viewModel: FactoryViewModel
    let factory: Factory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(factory.factoryName)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    
                    if factory.status.lowercased() == "active" {
                        Button {
                            viewModel.selectedFactory = factory
                        } label: {
                            Image(systemName: "pencil")
                        }
                        Button {
                            viewModel.prepareDelete(factoryId: factory.id)
                            viewModel.showDeletePopUp = true
                            if viewModel.deleteSuccess {
                                Task {
                                    await viewModel.fetchFactories(reset: true)
                                }
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                Text(factory.location)
                    .font(.system(size: 13, weight: .semibold))
                Text(factory.address)
                    .font(.system(size: 13, weight: .semibold))
            }
            
            HStack {
                Text("PlantHead")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
                Spacer()
                Text(factory.plantHeadName)
                    .font(.system(size: 13, weight: .semibold))
            }
            HStack {
                Text("Chief Supervisor")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
                Spacer()
                Text(factory.chiefSupervisorName)
                    .font(.system(size: 13, weight: .semibold))
            }
            HStack {
                Text("Status")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
                Spacer()
                Text(factory.status)
                    .customStatusStyle(status: factory.status)
            }
            HStack {
                VStack {
                    Text("Tools")
                    Text("\(factory.totalTools)")
                }
                VStack {
                    Text("Products")
                    Text("\(factory.totalProducts)")
                }
                VStack {
                    Text("Workers")
                    Text("\(factory.totalWorkers)")
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white))
        .shadow(color: .primaryLight.opacity(0.15), radius: 6, y: 2)
    }
}
