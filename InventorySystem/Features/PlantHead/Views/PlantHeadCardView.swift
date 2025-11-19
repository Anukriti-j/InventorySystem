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

                Button {
                    viewModel.prepareDelete(plantheadId: plantHead.id)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(.red.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
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

            // MARK: Status Badge
            Text(plantHead.isActive)
                .customStatusStyle(status: plantHead.isActive)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
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
