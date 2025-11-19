import SwiftUI
import Kingfisher

struct WorkerDetailCardView: View {
    let worker: Worker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let image = worker.profileImage {
                    KFImage(URL(string: image))
                        .placeholder { ProgressView() }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ProgressView()
                }
                Text(worker.workerName)
                    .font(.headline)
                Spacer()
            }
            HStack {
                Text("Bay")
                    .foregroundColor(.gray)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(worker.bayArea)
            }
            
            
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
        .allowsHitTesting(false)
        
    }
}

//#Preview {
//    WorkerDetailCardView(
//        worker: Worker(
//            id: <#T##Int#>,
//            workerName: <#T##String#>,
//            location: <#T##String#>,
//            bayArea: <#T##String#>,
//            status: <#T##String#>
//        )
//    )
//}
