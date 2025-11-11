import SwiftUI

struct WorkerInfoCardView: View {
    @Bindable var viewModel: OwnerWorkerViewModel
    let worker: Worker

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(worker.workerName)
                    .font(.headline)
                Spacer()
//                Button {
//                    viewModel.prepareDelete(workerId: worker.id)
//                } label: {
//                    Image(systemName: "trash")
//                        .foregroundColor(.red)
//                }
            }
            RowInfoView(label: "Bay Area", value: worker.bayArea)
            RowInfoView(label: "Factory", value: worker.factoryName)

            Text(worker.status)
                .font(.subheadline)
                .foregroundColor(worker.status.lowercased() == "active" ? .green : .red)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.white))
        .shadow(radius: 4)
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
