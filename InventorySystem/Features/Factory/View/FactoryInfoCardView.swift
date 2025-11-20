import SwiftUI

struct FactoryInfoCardView: View {
    @Bindable var viewModel: FactoryViewModel
    let factory: Factory
    let onCardTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(factory.factoryName)
                    .font(.title3.bold())
                    .lineLimit(1)

                Spacer()

                if factory.status.lowercased() == "active" {
                    Button {
                        viewModel.factoryToEdit = factory
                    } label: {
                        Image(systemName: "pencil")
                            .customEditButtonStyle()
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.prepareDelete(factoryId: factory.id)
                        viewModel.showDeletePopUp = true
                    } label: {
                        Image(systemName: "trash")
                            .customDeleteButtonStyle()
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(factory.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(factory.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Text("PlantHead").font(.caption).foregroundColor(.gray)
                Spacer()
                Text(factory.plantHeadName)
                    .font(.caption.bold())
            }

            HStack {
                Text("Chief Supervisor").font(.caption).foregroundColor(.gray)
                Spacer()
                Text(factory.chiefSupervisorName)
                    .font(.caption.bold())
            }

            HStack {
                Text("Status").font(.caption).foregroundColor(.gray)
                Spacer()
                Text(factory.status)
                    .customStatusStyle(status: factory.status)
            }

            HStack(spacing: 30) {
                VStack {
                    Text("Tools")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(factory.totalTools)")
                        .font(.title3.bold())
                }
                VStack {
                    Text("Products")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(factory.totalProducts)")
                        .font(.title3.bold())
                }
                VStack {
                    Text("Workers")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(factory.totalWorkers)")
                        .font(.title3.bold())
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(radius: 6))
        .padding(.horizontal, 12)
        .onTapGesture {
            onCardTap()
        }
        .allowsHitTesting(true)
    }
}
