import SwiftUI
import Kingfisher

struct WorkerInfoCardView: View {
    @Bindable var viewModel: WorkerViewModel
    let worker: Worker

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                KFImage(URL(string: worker.profileImage ?? ""))
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(worker.workerName)
                    .font(.headline)
                Spacer()
                if worker.status.lowercased() == "active" {
                    Button {
                        viewModel.prepareDelete(workerId: worker.id)
                        viewModel.showDeletePopUp = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .allowsHitTesting(true)
                }
            }

            RowInfoView(label: "Bay Area", value: worker.bayArea)
            RowInfoView(label: "Factory", value: worker.factoryName ?? "Not Found")

            HStack {
                Text("Status")
                    .foregroundColor(.gray)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(worker.status)
                    .customStatusStyle(status: worker.status)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(radius: 4)
        )
        .contentShape(Rectangle())
        .onTapGesture { }
    }
}

struct RowInfoView: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
        }
        .font(.system(size: 13, weight: .semibold))
    }
}
