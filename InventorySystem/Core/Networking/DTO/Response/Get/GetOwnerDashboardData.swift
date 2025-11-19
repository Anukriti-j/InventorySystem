import Foundation

struct DashboardData {
    let totalFactories: Int
    let totalWorkers: Int
    let totalCustomers: Int
    let totalRevenue: Double
    let totalOrders: Int
    let totalDistributors: Int
//    let productCategories: [ProductCategory]
//    let fastMovingTools: [AnalyseTool]
//    let slowMovingStocks: [Stock]
}

struct AnalyseTool: Identifiable {
    let id = UUID()
    let name: String
    let uses: Int
}

struct Stock: Identifiable {
    let id = UUID()
    let name: String
    let uses: Int
}
