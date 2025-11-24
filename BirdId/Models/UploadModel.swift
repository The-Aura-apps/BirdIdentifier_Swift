//
//  UploadModel.swift
//  BirdId
//
//  Created by ali bakhsha on 9/2/1404 AP.
//

import Foundation

struct UploadResponse: Decodable {
    let upload: Upload
    let observation: Observation
}

struct Upload: Decodable {
    let id: Int
    let fileName: String
    let mimeType: String
    let type: String
    let checksum: String
    let createdAt: String
}

struct Observation: Decodable {
    let deviceId: String
    let type: String
    let status: String
    let uploadId: Int
    let birdId: Int?
    let aiResult: String?
    let confidence: Double?
    let errorMessage: String?
    let id: String
    let createdAt: String
    let updatedAt: String
}
