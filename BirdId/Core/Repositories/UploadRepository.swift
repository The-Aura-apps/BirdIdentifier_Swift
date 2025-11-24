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
    func uploadMedia(
        file: Data,
        deviceId: String,
        type: String // "image" or "audio"
    ) -> AnyPublisher<UploadResponse, Error>
}

class UploadRepository: UploadRepositoryProtocol {

    private let api: ApiServiceProtocol
    
    init(api: ApiServiceProtocol = ApiService()) {
        self.api = api
    }
    
    func uploadMedia(
        file: Data,
        deviceId: String,
        type: String // "image" or "audio"
    ) -> AnyPublisher<UploadResponse, Error> {

        let params: [String: Any] = [
            "deviceId": "\(deviceId)",
            "type": type
        ]
        
        // Generate fileName based on type and timestamp
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName: String
        let mimeType: String
        
        if type == "image" {
            fileName = "photo_\(timestamp).jpg"
            mimeType = "image/jpeg"
        } else if type == "audio" {
            fileName = "recording_\(timestamp).m4a"
            mimeType = "audio/m4a"
        } else {
            fileName = "file_\(timestamp)"
            mimeType = "application/octet-stream"
        }
        
        let files: [String: (data: Data, fileName: String, mimeType: String)] = [
            "file": (file, fileName, mimeType)
        ]
        
        return api.multipartRequest(
            Constants.Urls.uploads,
            method: .post,
            parameters: params,
            files: files,
            headers: nil,
            expecting: UploadResponse.self
        )
    }
}
