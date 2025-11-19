import SwiftUI
import Kingfisher

struct ProductInfoCardView: View {
    @Bindable var viewModel: ProductsViewModel
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                KFImage(URL(string: product.image ?? ""))
                    .placeholder { Image(systemName: "photo").font(.system(size: 40)) }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name).font(.headline)
                    Text(product.productDescription).font(.subheadline).lineLimit(2)
                    Text(product.categoryName).font(.caption).foregroundColor(.purple)
                }
            }

            Divider()

            HStack(spacing: 20) {
                infoItem("Price", "$\(product.price)")
                infoItem("Stock", "\(product.quantity)")
                infoItem("Reward", "\(product.rewardPoint) pts")
            }
            .font(.caption).foregroundColor(.secondary)

            Divider()

            HStack {
                Button(role: .destructive) {
                    viewModel.prepareDelete(productId: product.id)
                } label: {
                    Image(systemName: "trash").font(.title3).foregroundColor(.red).frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                Spacer()
                
                // MARK: update the modifier to customstatusstyle
                Text(product.quantity > 0 ? "In Stock" : "Out of Stock")
                    .font(.caption2).bold()
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background((product.quantity > 0 ? Color.green : Color.red).opacity(0.15))
                    .foregroundColor(product.quantity > 0 ? .green : .red)
                    .clipShape(Capsule())
                
                Spacer()

                Button {
                   // viewModel.editingProduct = product
                    viewModel.showEditSheet = true
                } label: {
                    Image(systemName: "pencil").font(.title3).foregroundColor(.purple).frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(radius: 6))
        .padding(.horizontal, 12)
    }

    private func infoItem(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title).font(.caption2).foregroundColor(.secondary)
            Text(value).font(.caption).fontWeight(.medium)
        }
    }
}
