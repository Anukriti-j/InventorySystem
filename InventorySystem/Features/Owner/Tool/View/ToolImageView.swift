import SwiftUI
import Kingfisher

struct ToolImageView: View {
    @Binding var selectedImage: UIImage?
    var urlString: String?
    @State private var isShowingImagePicker = false

    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let url = urlString, let imageURL = URL(string: url) {
                    KFImage(imageURL)
                        .placeholder { Color.gray.opacity(0.2) }
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.6))
                        )
                }

                Button {
                    isShowingImagePicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundStyle(.purple)
                        .background(Circle().fill(.white))
                }
                .offset(x: -8, y: -8)
            }
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 3)
            .onTapGesture { isShowingImagePicker = true }

            Text(selectedImage == nil && urlString == nil ? "Add Image" : "Change Image")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
    }
}
