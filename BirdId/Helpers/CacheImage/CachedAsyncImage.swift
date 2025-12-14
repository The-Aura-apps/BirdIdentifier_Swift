//
//  CachedAsyncImage.swift
//  BirdId
//
//  Created by ali bakhsha on 9/21/1404 AP.
//


import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder:  () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        let cacheKey = url.absoluteString
        
        // Check cache first
        if let cachedImage = ImageCacheManager.shared.getImage(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        // Download image
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let downloadedImage = UIImage(data:  data) else {
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            
            // Save to cache
            ImageCacheManager.shared.setImage(downloadedImage, forKey: cacheKey)
            
            DispatchQueue.main.async {
                self.image = downloadedImage
                isLoading = false
            }
        }.resume()
    }
}

// MARK: - Convenience init with phase-like API
extension CachedAsyncImage where Placeholder == Color {
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: url,
            content: content,
            placeholder: { Color.gray.opacity(0.3) }
        )
    }
}
