import SwiftUI

struct CustomHeader: View {
    //let title: String
    @Binding var showMenu: Bool
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Button { withAnimation { showMenu.toggle() } }
            label: { Image(systemName: "line.3.horizontal").font(.title2) }

            Spacer()
//            Text(title)
//                .font(.title2.bold())

            Spacer()

            if let action = trailingAction {
                Button("Add +", action: action)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            } else {
                Color.clear.frame(width: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 12)
        .background(.white)  
        .overlay(alignment: .bottom) { Divider() }
    }
}
