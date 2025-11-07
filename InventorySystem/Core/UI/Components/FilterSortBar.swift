import SwiftUI

struct FilterSortBar: View {
    @Binding var showFilterSheet: Bool
    @Binding var showSortSheet: Bool
    
    var body: some View {
        HStack {
            Button {
                showFilterSheet.toggle()
            } label: {
                Label("Filter", systemImage: "slider.horizontal.3")
                    .font(.subheadline)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            Button {
                showSortSheet.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
                    .font(.subheadline)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    FilterSortBar(showFilterSheet: .constant(true), showSortSheet: .constant(true))
}
