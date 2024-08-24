//
//  ImageCache.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
//

//
//  ImageCache.swift
//  News Reader
//
//  Created by Benjamin Couch on 24/8/2024.
//
import SwiftUI

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

struct CachedAsyncImage: View {
    let url: URL
    let placeholder: Image
    
    @State private var cachedImage: UIImage? = nil
    
    var body: some View {
        if let cachedImage = cachedImage {
            Image(uiImage: cachedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            placeholder
                .resizable()
                .aspectRatio(contentMode: .fill)
                .onAppear {
                    loadImage()
                }
        }
    }
    
    private func loadImage() {
        let cacheKey = NSString(string: url.absoluteString)
        
        if let cachedImage = ImageCache.shared.object(forKey: cacheKey) {
            self.cachedImage = cachedImage
        } else {
            downloadImage(from: url) { image in
                if let image = image {
                    ImageCache.shared.setObject(image, forKey: cacheKey)
                    self.cachedImage = image
                }
            }
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
