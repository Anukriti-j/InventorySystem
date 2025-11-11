import SwiftUI
import Kingfisher

struct ToolInfoCardView: View {
    @Bindable var viewModel: OwnerToolsViewModel
    var tool: Tool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top, spacing: 12) {
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
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(tool.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(tool.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Label(tool.categoryName, systemImage: "tag.fill")
                            .font(.caption)
                            .foregroundColor(.purple)
                        Spacer()
                        Text(tool.status.capitalized)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor(tool.status).opacity(0.1))
                            .foregroundColor(statusColor(tool.status))
                            .clipShape(Capsule())
                    }
                }
            }
            
            Divider()
            
            // MARK: - Details Row
            HStack(spacing: 16) {
                infoItem(title: "Stock", value: "\(tool.availableQuantity)")
                infoItem(title: "Threshold", value: "\(tool.threshold)")
                infoItem(title: "Expensive", value: tool.isExpensive == "true" ? "Yes" : "No")
                infoItem(title: "Perishable", value: tool.isPerishable == "true" ? "Yes" : "No")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Divider()
            
            // MARK: - Actions
            HStack {
                Button {
                    viewModel.prepareDelete(toolId: tool.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button {
                    viewModel.showAddSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .green
        case "inactive": return .gray
        case "low stock": return .orange
        default: return .blue
        }
    }
    
    private func infoItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}
