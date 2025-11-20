import SwiftUI
import Kingfisher

struct ToolInfoCardView: View {
    @Bindable var viewModel: ToolsListViewModel
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
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(tool.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(tool.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(tool.categoryName)
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Text("Expensive: \(tool.isExpensive)")
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Text("Perishable: \(tool.isPerishable)")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .alignmentGuide(.top) { _ in 0 } // force alignment at top
            }
            
            Divider()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], alignment: .center, spacing: 12) {
                infoItem(title: "Available", value: "\(tool.availableQuantity)")
                infoItem(title: "Total", value: "\(tool.totalQuantity)")
                infoItem(title: "Threshold", value: "\(tool.threshold)")
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            HStack(alignment: .center) {
                if tool.status.lowercased() == "active" {
                    Button(role: .destructive) {
                        viewModel.prepareDelete(toolId: tool.id)
                    } label: {
                        Image(systemName: "trash")
                            .customDeleteButtonStyle()
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(tool.status)
                        .customStatusStyle(status: tool.status)
                    Text(tool.stockStatus)
                        .customStatusStyle(status: tool.stockStatus)
                    
                    Spacer()
                    
                    Button {
                        viewModel.editingTool = tool
                        viewModel.showEditSheet = true
                    } label: {
                        Image(systemName: "pencil")
                            .customEditButtonStyle()
                    }
                    .buttonStyle(.plain)
                }
                
                if tool.status.lowercased() == "inactive" {
                    Text(tool.status)
                        .customStatusStyle(status: tool.status)
                }
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
