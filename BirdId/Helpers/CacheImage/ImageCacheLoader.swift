//
//  ImageCacheManager. swift
//  BirdId
//
//  Created by ali bakhsha
//

import UIKit
import SwiftUI

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Setup NSCache
        cache.countLimit = 100 // Maximum 100 images in memory
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB memory limit
        
        // Setup disk cache directory
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Memory Cache
    
    func getImage(forKey key: String) -> UIImage? {
        // First check memory cache
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        
        // Then check disk cache
        if let image = loadImageFromDisk(forKey: key) {
            // Store in memory cache for faster access
            cache.setObject(image, forKey: key as NSString)
            return image
        }
        
        return nil
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        // Save to memory cache
        cache.setObject(image, forKey: key as NSString)
        
        // Save to disk cache
        saveImageToDisk(image, forKey: key)
    }
    
    // MARK: - Disk Cache
    
    private func loadImageFromDisk(forKey key: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(key.toBase64())
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    private func saveImageToDisk(_ image: UIImage, forKey key: String) {
        guard let data = image.jpegData(compressionQuality:  0.8) else { return }
        
        let fileURL = cacheDirectory.appendingPathComponent(key.toBase64())
        try? data.write(to: fileURL)
    }
    
    // MARK: - Clear Cache
    
    func clearMemoryCache() {
        cache.removeAllObjects()
    }
    
    func clearDiskCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func clearAllCache() {
        clearMemoryCache()
        clearDiskCache()
    }
    
    // MARK: - Cache Size
    
    func getDiskCacheSize() -> Int64 {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        return files.reduce(0) { size, file in
            let fileSize = (try? file.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return size + Int64(fileSize)
        }
    }
}

// MARK: - String Extension for Base64
extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
    }
}
