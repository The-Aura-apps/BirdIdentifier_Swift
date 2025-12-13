//
//  HabitatDetailModels.swift
//  BirdId
//
//  Created by ali bakhsha on 9/21/1404 AP.
//

import Foundation

// MARK: - Habitat Detail Response
struct HabitatDetailResponse: Codable {
    let id: Int
    let name: String
    let description: String
    let birds: [HabitatBirdDetail]
}

// MARK: - Habitat Bird
struct HabitatBirdDetail:  Codable, Identifiable {
    let id: Int
    let scientificName: String
    let description: String
    let behavior: String
    let nestingHabits: String
    let feedingHabits: String
    let eggsDescription: String
    let coolFacts: String
    let size: BirdSize
    let lifeExpectancyYears: String
    let taxonomy: TaxonomyHabitatDetail
    let conservationStatus: ConservationStatusHabitatDetail
    let habitats: [BasicHabitat]
    
    // Helper computed property to get common name
    var commonName: String {
        // Since API doesn't return commonNames in this response,
        // we'll use scientific name or you can add it if API provides it
        return scientificName
    }
    
    // Helper to get image URL if available
    var imageUrl: String? {
        // Add this if your API provides image URLs
        return nil
    }
}

// MARK: - Bird Size
struct BirdSize:  Codable {
    let lengthCm:  SizeRange
    let wingspanCm: SizeRange
    let weightGrams: SizeRange
}

struct SizeRange: Codable {
    let max: Double
    let min: Double
}

// MARK: - Taxonomy
struct TaxonomyHabitatDetail:  Codable {
    let id:  Int
    let phylum: String
    let `class`: String
    let order: String
    let family: String
    let genus: String
    let createdAt: String
    let updatedAt: String
}

// MARK: - Conservation Status
struct ConservationStatusHabitatDetail: Codable {
    let id: Int
    let code: String
    let fullName: String
    let description: String
    let severityLevel: Int
    let authority:  String
    let createdAt:  String
    let updatedAt:  String
}

// MARK:  - Basic Habitat
struct BasicHabitat: Codable {
    let id: Int
    let name: String
    let description:  String
}
