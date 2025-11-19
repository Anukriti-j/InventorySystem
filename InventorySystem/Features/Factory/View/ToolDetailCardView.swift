import SwiftUI
import Kingfisher

struct ToolCardView: View {
    let tool: Tool

    var body: some View {
        HStack(spacing: 14) {
            KFImage(URL(string: tool.imageURL))
                .placeholder { Color.gray.opacity(0.2) }
                .resizable()
                .scaledToFill()
                .frame(width: 55, height: 55)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tool.name)
                    .font(.headline)
                Text("Category: \(tool.categoryName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
