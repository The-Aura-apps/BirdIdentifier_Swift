//
//  DeviceSettingsModel.swift
//  BirdId
//
//  Created by ali bakhsha on 10/8/1404 AP.
//


import Foundation

// MARK: - Request Model
struct DeviceSettingsRequest: Encodable {
    let deviceId: String
    let identificationMethod: IdentificationMethod
    let userPurpose: UserPurpose
    
    enum CodingKeys: String, CodingKey {
        case deviceId
        case identificationMethod
        case userPurpose
    }
}

// MARK: - Identification Method Enum
enum IdentificationMethod: String, Codable {
    case photo = "photo"
    case sound = "sound"
    case photoSound = "photo_sound"
    
    init(fromIndex index: Int) {
        switch index {
        case 0: self = .photo
        case 1: self = .sound
        case 2: self = .photoSound
        default: self = .photoSound
        }
    }
}

// MARK: - User Purpose Enum
enum UserPurpose: String, Codable {
    case forFun = "for_fun"
    case hunting = "hunting"
    case keepingBirds = "keeping_birds"
    case justInterested = "just_interested"
    
    init(fromIndex index: Int) {
        switch index {
        case 0: self = .forFun
        case 1: self = .hunting
        case 2: self = .keepingBirds
        case 3: self = .justInterested
        default: self = .forFun
        }
    }
}

// MARK: - Response Model (if needed)
struct DeviceSettingsResponse: Decodable {
    let success: Bool?
    let message: String?
    
    // Add more fields if your API returns them
}
