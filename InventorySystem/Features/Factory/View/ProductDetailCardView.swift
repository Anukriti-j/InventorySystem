import SwiftUI
import Kingfisher

struct ProductCardView: View {
    let product: Product

    var body: some View {
        HStack(spacing: 14) {
            KFImage(URL(string: product.image ?? ""))
                .placeholder { Color.gray.opacity(0.2) }
                .resizable()
                .scaledToFill()
                .frame(width: 55, height: 55)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                Text("Category: \(product.categoryName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Qty: \(product.quantity)")
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
