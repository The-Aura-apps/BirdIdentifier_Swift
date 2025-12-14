//
//  UploadRepository.swift
//  BirdId
//
//  Created by ali bakhsha on 9/2/1404 AP.
//


import Foundation
import Combine
import UIKit
import Alamofire

protocol UploadRepositoryProtocol {
    func uploadAndIdentify(
        file: Data,
        deviceId: String,
        type: String
    ) -> AnyPublisher<UploadResponse, Error>
}

class UploadRepository: UploadRepositoryProtocol {
    
    private let api: ApiServiceProtocol
    
    init(api: ApiServiceProtocol = ApiService()) {
        self.api = api
    }
    
    func uploadAndIdentify(
        file: Data,
        deviceId: String,
        type: String
    ) -> AnyPublisher<UploadResponse, Error> {
        
        print("🚀 ============ شروع آپلود ============")
        print("📱 Device ID: \(deviceId)")
        print("📄 Type: \(type)")
        print("📏 File Size: \(file.count) bytes")
        
        return performUpload(file: file, deviceId: deviceId, type: type, expecting: UploadResponse.self)
            .tryMap { uploadResponse -> UploadResponse in
                print("✅ ============ دریافت پاسخ از سرور ============")
                print("🎯 Success: \(uploadResponse.success)")
                print("🎯 Status: \(uploadResponse.status)")
                print("🎯 Confidence: \(uploadResponse.confidence)")
                print("📊 Observation ID: \(uploadResponse.observation.id)")
                
                // اطلاعات bird
                let bird = uploadResponse.bird
                print("🐦 Bird ID: \(bird.id)")
                print("🐦 Scientific Name: \(bird.scientificName)")
                print("🐦 Common Names: \(bird.commonNames.count)")
                print("🐦 Media Count: \(bird.media.count)")
                
                // بررسی optional values
                if let description = bird.description {
                    print("📝 Description length: \(description.count) characters")
                } else {
                    print("⚠️ Description is nil")
                }
                
                if let confidenceValue = Double(uploadResponse.confidence) {
                    print("📈 Confidence Value: \(confidenceValue * 100)%")
                }
                
                // بررسی وضعیت
                if uploadResponse.status.lowercased() != "completed" {
                    print("⚠️ Status is not completed: \(uploadResponse.status)")
                    throw NSError(
                        domain: "BirdId",
                        code: 1001,
                        userInfo: [NSLocalizedDescriptionKey: "Processing is not completed yet. Status: \(uploadResponse.status)"]
                    )
                }
                
                if !uploadResponse.success {
                    print("❌ Upload was not successful")
                    throw NSError(
                        domain: "BirdId",
                        code: 1002,
                        userInfo: [NSLocalizedDescriptionKey: "Upload was not successful"]
                    )
                }
                
                print("✅ ============ پاسخ معتبر است ============")
                return uploadResponse
            }
            .handleEvents(
                receiveSubscription: { _ in
                    print("🔗 Subscription started for upload")
                },
                receiveOutput: { birdDetail in
                    print("🎉 Successfully extracted bird detail")
                    print("🐦 Bird Name: \(birdDetail.bird.scientificName)")
                    print("🐦 Bird ID: \(birdDetail.bird.id)")
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("🏁 Upload process completed successfully")
                    case .failure(let error):
                        print("💥 Upload process failed with error: \(error.localizedDescription)")
//                        print("🔍 Error Type: \(type(of: error))")
                        print("📚 Error Details: \(error)")
                    }
                },
                receiveCancel: {
                    print("⏹️ Upload process cancelled")
                }
            )
            .eraseToAnyPublisher()
    }
    
    private func performUpload<T: Decodable>(
        file: Data,
        deviceId: String,
        type: String,
        expecting: T.Type
    ) -> AnyPublisher<T, Error> {
        
        let params: [String: Any] = [
            "deviceId": deviceId,
            "type": type
        ]
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let (fileName, mimeType): (String, String) = {
            switch type {
            case "image":
                return ("photo_\(timestamp).jpg", "image/jpeg")
            case "audio":
                return ("recording_\(timestamp).m4a", "audio/m4a")
            default:
                return ("file_\(timestamp)", "application/octet-stream")
            }
        }()
        
        print("📤 Preparing upload...")
        print("📁 File Name: \(fileName)")
        print("📋 MIME Type: \(mimeType)")
        print("🔗 Endpoint: \(Constants.Urls.uploads)")
        
        let files: [String: (data: Data, fileName: String, mimeType: String)] = [
            "file": (file, fileName, mimeType)
        ]
        
        return api.multipartRequest(
            Constants.Urls.uploads,
            method: .post,
            parameters: params,
            files: files,
            headers: nil,
            expecting: expecting
        )
        .handleEvents(
            receiveSubscription: { _ in
                print("🌐 API request starting...")
            },
            receiveOutput: { _ in
                print("📥 Received response from server")
            },
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("✅ API request completed")
                case .failure(let error):
                    print("❌ API request failed: \(error)")
                }
            }
        )
        .eraseToAnyPublisher()
    }
}
