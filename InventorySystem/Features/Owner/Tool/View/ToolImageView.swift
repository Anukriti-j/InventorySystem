import SwiftUI

struct ToolImageView: View {
    /// Selected image from user's photo library
    @Binding var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                // MARK: - Image Display
                Group {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.6))
                        }
                    }
                }
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 2)
                .contentShape(Rectangle()) // makes the image tappable
                
                // MARK: - Pick Image Button
                Button {
                    isShowingImagePicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundStyle(.purple)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 3)
                }
                .offset(x: -8, y: -8)
            }
            .onTapGesture {
                isShowingImagePicker = true
            }
            
            Text(selectedImage == nil ? "Add Tool Image" : "Change Image")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .padding(.vertical)
    }
}
