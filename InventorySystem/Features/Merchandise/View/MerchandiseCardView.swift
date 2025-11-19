import SwiftUI
import Kingfisher

struct MerchandiseCardView: View {
    @Bindable var viewModel: MerchandiseViewModel
    let merchandise: Merchandise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                KFImage(URL(string: merchandise.imageURL))
                    .placeholder {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                            Image(systemName: "suitcase.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                
                
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(merchandise.name)
                        .font(.headline)
                    
                    Label("\(merchandise.requiredPoints) pts", systemImage: "star.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Label("Qty: \(merchandise.availableQuantity)", systemImage: "cube.box.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(merchandise.stockStatus)
                        .customStatusStyle(status: merchandise.stockStatus)
                    
                    Text(merchandise.status)
                        .customStatusStyle(status: merchandise.status)
                }
                
                Spacer()
            }
            .padding()
            
            Divider()
            
            HStack(spacing: 0) {
                Button {
                    viewModel.selectedMerchandise = merchandise
                    viewModel.showEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                }
                .foregroundColor(.blue)
                .padding(.vertical, 12)
                
                Divider().frame(height: 20)
                
                Button {
                    viewModel.merchandiseToDelete = merchandise
                    viewModel.showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .foregroundColor(.red)
                .padding(.vertical, 12)
            }
        }
        .sheet(isPresented: $viewModel.showEditSheet, content: {
            if let selectedMerchandise = viewModel.selectedMerchandise {
                EditMerchandiseView(merchandise: selectedMerchandise)
                
            }
        })
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 1)
    }
}
