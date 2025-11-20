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
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], alignment: .center, spacing: 12) {
                infoItem(title: "Price", value: "$\(product.price)")
                infoItem(title: "Stock", value: "\(product.quantity)")
                infoItem(title: "Reward", value: "\(product.rewardPoint) pts")
            }
            .frame(maxWidth: .infinity)
           
            Divider()
            
            HStack {
                Button(role: .destructive) {
                    viewModel.prepareDelete(productId: product.id)
                } label: {
                    Image(systemName: "trash")
                        .customDeleteButtonStyle()
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(product.stockStatus)
                    .customStatusStyle(status: product.stockStatus)
                
                Spacer()
                
                Button {
                    viewModel.editingProduct = product
                    viewModel.showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                        .customEditButtonStyle()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 8)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(radius: 6))
        .padding(.horizontal, 12)
    }
    
    private func infoItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
        }
    }
}
