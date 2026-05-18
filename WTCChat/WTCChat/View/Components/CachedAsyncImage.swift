import SwiftUI

struct CachedAsyncImage: View {
    let urlString: String?
    let cacheKey: String?
    let placeholderSystemName: String
    var isGroup: Bool = false
    
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: placeholderSystemName)
                    .resizable()
                    .scaledToFit()
                    .padding(isGroup ? 14 : 0)
                    .foregroundColor(.cinza)
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        if let key = cacheKey, let cachedImage = ImageCache.shared.get(forKey: key) {
            self.image = cachedImage
            return
        }
        
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let downloadedImage = UIImage(data: data) {
                if let key = cacheKey {
                    ImageCache.shared.set(downloadedImage, forKey: key)
                }
                DispatchQueue.main.async { self.image = downloadedImage }
            }
        }
        .resume()
    }
}
