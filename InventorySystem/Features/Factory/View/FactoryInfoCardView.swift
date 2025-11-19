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
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(width: 36, height: 36)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }

                    Button {
                        viewModel.prepareDelete(factoryId: factory.id)
                        viewModel.showDeletePopUp = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                            .frame(width: 36, height: 36)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
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
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onCardTap()
        }
    }
}
