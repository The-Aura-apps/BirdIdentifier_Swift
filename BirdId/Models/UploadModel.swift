//
//  UploadModel.swift
//  BirdId
//
//  Created by ali bakhsha on 9/2/1404 AP.
//

import Foundation

// MARK: - Main Upload Response (Root)
struct UploadResponse: Decodable {
    let success: Bool
    let bird: BirdDetailResponse
    let confidence: String
    let status: String
    let observation: ObservationInfo
    
    enum CodingKeys: String, CodingKey {
        case success, bird, confidence, status, observation
    }
}

// MARK: - Observation Info
struct ObservationInfo: Decodable {
    let id: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, createdAt
    }
}

// MARK: - Bird Detail Response
struct BirdDetailResponse: Decodable {
    let id: Int
    let scientificName: String
    let description: String?
    let behavior: String?
    let nestingHabits: String?
    let feedingHabits: String?
    let eggsDescription: String?
    let coolFacts: String?
    let lifeExpectancyYears: String?
    let size: Size
    let commonNames: [CommonName]
    let taxonomy: Taxonomy
    let conservationStatus: ConservationStatus
    let habitats: [BirdHabitat]
    let birdFoods: [BirdFoodWrapper]
    let distributions: [Distribution]
    let media: [Media]
    
    enum CodingKeys: String, CodingKey {
        case id, scientificName, description, behavior, nestingHabits
        case feedingHabits, eggsDescription, coolFacts, lifeExpectancyYears
        case size, commonNames, taxonomy, conservationStatus, habitats
        case birdFoods, distributions, media
    }
}

// MARK: - Size
struct Size: Decodable {
    let lengthCm: RangeValue
    let wingspanCm: RangeValue
    let weightGrams: RangeValue
    
    enum CodingKeys: String, CodingKey {
        case lengthCm, wingspanCm, weightGrams
    }
}

struct RangeValue: Decodable {
    let max: Double?
    let min: Double?
    
    enum CodingKeys: String, CodingKey {
        case max, min
    }
    
    // Convert to Int if needed
    var maxInt: Int? {
        guard let max = max else { return nil }
        return Int(max)
    }
    
    var minInt: Int? {
        guard let min = min else { return nil }
        return Int(min)
    }
}

// MARK: - Common Names
struct CommonName: Decodable {
    let id: Int
    let name: String
    let language: String
    let region: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, language, region, createdAt, updatedAt
    }
}

// MARK: - Taxonomy
struct Taxonomy: Decodable {
    let id: Int
    let phylum: String?
    let `class`: String?
    let order: String?
    let family: String?
    let genus: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, phylum, `class`, order, family, genus, createdAt, updatedAt
    }
}

// MARK: - Conservation Status
struct ConservationStatus: Decodable {
    let id: Int
    let code: String
    let fullName: String
    let description: String?
    let severityLevel: Int?
    let authority: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, code, fullName, description, severityLevel, authority, createdAt, updatedAt
    }
}

// MARK: - Habitat
struct BirdHabitat: Decodable {
    let id: Int
    let name: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
    }
}

// MARK: - Bird Foods
struct BirdFoodWrapper: Decodable {
    let id: Int
    let isActive: Bool?
    let createdAt: String
    let updatedAt: String
    let food: Food
    
    enum CodingKeys: String, CodingKey {
        case id, isActive, createdAt, updatedAt, food
    }
}

struct Food: Decodable {
    let id: Int
    let name: String
    let description: String?
    let imageStorageKey: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, imageStorageKey
    }
}

// MARK: - Distribution
struct Distribution: Decodable {
    let id: Int
    let month: Int
    let season: String
    let location: Location
    let presenceScore: Double?
    let description: String?
    let countries: [String]
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, month, season, location, presenceScore, description, countries, createdAt, updatedAt
    }
}

struct Location: Decodable {
    let region: String?
    let country: String
    let coordinates: Coordinates
    
    enum CodingKeys: String, CodingKey {
        case region, country, coordinates
    }
}

struct Coordinates: Decodable {
    let lat: Double
    let lng: Double
    
    enum CodingKeys: String, CodingKey {
        case lat, lng
    }
}

// MARK: - Media
struct Media: Decodable {
    let id: Int
    let storageKey: String
    let type: String
    let size: String?
    let caption: String?
    let source: String?
    let attribution: String?
    let orderIndex: Int
    let metadata: MediaMetadata?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, storageKey, type, size, caption, source, attribution
        case orderIndex, metadata, createdAt, updatedAt
    }
}

struct MediaMetadata: Decodable {
    let thumbnailKey: String?
    
    enum CodingKeys: String, CodingKey {
        case thumbnailKey
    }
}
