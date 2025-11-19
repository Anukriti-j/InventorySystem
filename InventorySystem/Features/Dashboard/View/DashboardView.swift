import SwiftUI

struct DashboardView: View {
    let userRole: UserRole?
    
    init(userRole: UserRole?) {
        self.userRole = userRole
    }
    var body: some View {
        Text("Dashboard View")
    }
}
//struct DashboardView: View {
//    let userRole: UserRole?
//
//    init(userRole: UserRole?) {
//        self.userRole = userRole
//    }
//
////        private let dashboardData = DashboardData(
////            totalFactories: 14,
////            totalWorkers: 100,
////            totalCustomers: 20,
////            totalRevenue: 201000,
////            totalOrders: 100,
////            totalDistributors: 500,
//////            productCategories: [
//////                ProductCategory(name: "Cutting", value: 500),
//////                ProductCategory(name: "Sharpening", value: 5000)
//////            ],
//////            fastMovingTools: [
//////                Tool(name: "Power drill", uses: 340),
//////                Tool(name: "Screwdriver", uses: 500)
//////            ],
//////            slowMovingStocks: [
//////                Stock(name: "Grinder", uses: 45),
//////                Stock(name: "Chisel", uses: 20)
//////            ]
////        )
//
//        var body: some View {
////            Group {
////                if userRole == .owner {
////                    NavigationView {
////                        ScrollView {
////                            VStack(spacing: 20) {
////                                // Top Stats Grid
////                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
////                                    StatCard(title: "Total Factories", value: "\(dashboardData.totalFactories)", icon: "building.2")
////                                    StatCard(title: "Total Workers", value: "\(dashboardData.totalWorkers)", icon: "person.3")
////                                    StatCard(title: "Total Customers", value: "\(dashboardData.totalCustomers)", icon: "person.2")
////                                    StatCard(title: "Total Revenue", value: "₹\(formatNumber(dashboardData.totalRevenue))", icon: "indianrupeesign.circle")
////                                    StatCard(title: "Total Orders", value: "\(dashboardData.totalOrders)", icon: "cart")
////                                    StatCard(title: "Total Distributors", value: "\(dashboardData.totalDistributors)", icon: "truck.box")
////                                }
////
////                                // Products in Categories Chart
////                                VStack(alignment: .leading, spacing: 12) {
////                                    Text("Products in Categories")
////                                        .font(.headline)
////                                        .padding(.horizontal)
////
////                                    PieChartView(data: dashboardData.productCategories)
////                                        .frame(height: 250)
////                                        .padding()
////                                        .background(Color(.systemBackground))
////                                        .cornerRadius(12)
////                                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
////                                }
////
////                                // Fast Moving Tools and Slow Moving Stocks
////                                HStack(alignment: .top, spacing: 16) {
////                                    // Fast Moving Tools
////                                    VStack(alignment: .leading, spacing: 12) {
////                                        Text("Fast Moving Tools")
////                                            .font(.headline)
////
////                                        ForEach(dashboardData.fastMovingTools) { tool in
////                                            ToolRow(name: tool.name, uses: tool.uses, color: .green)
////                                        }
////                                    }
////                                    .frame(maxWidth: .infinity)
////                                    .padding()
////                                    .background(Color(.systemBackground))
////                                    .cornerRadius(12)
////                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
////
////                                    // Slow Moving Stocks
////                                    VStack(alignment: .leading, spacing: 12) {
////                                        Text("Slow Moving Stocks")
////                                            .font(.headline)
////
////                                        ForEach(dashboardData.slowMovingStocks) { stock in
////                                            ToolRow(name: stock.name, uses: stock.uses, color: .orange)
////                                        }
////                                    }
////                                    .frame(maxWidth: .infinity)
////                                    .padding()
////                                    .background(Color(.systemBackground))
////                                    .cornerRadius(12)
////                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
////                                }
////                            }
////                            .padding()
////                        }
////                        .navigationTitle("Owner Dashboard")
////                        .background(Color(.systemGroupedBackground))
////                    }
////                } else {
////                    Text("Access Denied")
////                        .font(.title2)
////                        .foregroundColor(.secondary)
////                }
////            }
////        }
////
////        private func formatNumber(_ number: Double) -> String {
////            let formatter = NumberFormatter()
////            formatter.numberStyle = .decimal
////            formatter.maximumFractionDigits = 0
////            return formatter.string(from: NSNumber(value: number)) ?? "\(Int(number))"
////        }
//}
//
//struct StatCard: View {
//    let title: String
//    let value: String
//    let icon: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Image(systemName: icon)
//                    .foregroundColor(.blue)
//                    .font(.title3)
//                Spacer()
//            }
//
//            Text(value)
//                .font(.title2)
//                .fontWeight(.bold)
//
//            Text(title)
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
//    }
//}
//
//struct ToolRow: View {
//    let name: String
//    let uses: Int
//    let color: Color
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(name)
//                .font(.subheadline)
//                .fontWeight(.medium)
//
//            HStack {
//                Text("\(uses) uses")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//
//                Spacer()
//
//                Image(systemName: "arrow.up.right")
//                    .font(.caption)
//                    .foregroundColor(color)
//            }
//        }
//        .padding(.vertical, 8)
//    }
//}
//
//struct PieChartView: View {
//    let data: [ProductCategory]
//
//    var total: Double {
//        data.reduce(0) { $0 + $1.value }
//    }
//
//    var body: some View {
//        HStack(spacing: 40) {
//            // Pie Chart
//            ZStack {
//                ForEach(Array(data.enumerated()), id: \.element.id) { index, category in
//                    PieSlice(
//                        startAngle: startAngle(for: index),
//                        endAngle: endAngle(for: index)
//                    )
//                    .fill(colorForIndex(index))
//                }
//            }
//            .frame(width: 180, height: 180)
//
//            // Legend
//            VStack(alignment: .leading, spacing: 12) {
//                ForEach(Array(data.enumerated()), id: \.element.id) { index, category in
//                    HStack(spacing: 8) {
//                        Circle()
//                            .fill(colorForIndex(index))
//                            .frame(width: 12, height: 12)
//
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text(category.name)
//                                .font(.subheadline)
//                                .fontWeight(.medium)
//
//                            Text("\(Int(category.value))")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    private func startAngle(for index: Int) -> Angle {
//        let sum = data.prefix(index).reduce(0.0) { $0 + $1.value }
//        return Angle(degrees: (sum / total) * 360 - 90)
//    }
//
//    private func endAngle(for index: Int) -> Angle {
//        let sum = data.prefix(index + 1).reduce(0.0) { $0 + $1.value }
//        return Angle(degrees: (sum / total) * 360 - 90)
//    }
//
//    private func colorForIndex(_ index: Int) -> Color {
//        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red]
//        return colors[index % colors.count]
//    }
//}
//
//struct PieSlice: Shape {
//    let startAngle: Angle
//    let endAngle: Angle
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius = min(rect.width, rect.height) / 2
//
//        path.move(to: center)
//        path.addArc(
//            center: center,
//            radius: radius,
//            startAngle: startAngle,
//            endAngle: endAngle,
//            clockwise: false
//        )
//        path.closeSubpath()
//
//        return path
//    }
//}
////
////#Preview {
////    DashboardView()
////}
