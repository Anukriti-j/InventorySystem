import SwiftUI
import Kingfisher

struct ToolInfoCardView: View {
    @Bindable var viewModel: OwnerToolsViewModel
    var tool: Tool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top, spacing: 16) {
                KFImage(URL(string: tool.imageURL))
                    .placeholder {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(tool.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(tool.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    Text(tool.categoryName)
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
            
            Divider()
            
            HStack(spacing: 20) {
                infoItem(title: "Available", value: "\(tool.availableQuantity)")
                infoItem(title: "Total", value: "\(tool.totalQuantity)")
                infoItem(title: "Threshold", value: "\(tool.threshold)")
                infoItem(title: "Expensive", value: tool.isExpensive == "true" ? "Yes" : "No")
                infoItem(title: "Perishable", value: tool.isPerishable == "true" ? "Yes" : "No")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Divider()
            
            HStack {
                if tool.status.lowercased() == "active" {
                    Button(role: .destructive) {
                        viewModel.prepareDelete(toolId: tool.id)
                    } label: {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.red)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    
                    Spacer()
                }
                
                Text(tool.status)
                    .customStatusStyle(status: tool.status)
                
                if tool.status.lowercased() == "active" {
                    Text(tool.stockStatus)
                        .customStatusStyle(status: tool.stockStatus)
                    
                    Spacer()
                    
                    Button {
                        viewModel.editingTool = tool
                        viewModel.showEditSheet = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.title3)
                            .foregroundColor(.purple)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                } 
            }
            .padding(.top, 8)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal, 12)
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {}
    }
    
    private func infoItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}
