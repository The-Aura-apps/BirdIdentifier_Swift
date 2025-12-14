//
//  BirdHabitatModel.swift
//  BirdId
//
//  Created by ali bakhsha on 9/22/1404 AP.
//

import Foundation

// MARK: - Bird Habitat Simple Model
struct BirdHabitatSimple: Codable, Identifiable {
    let birdId: Int
    let scientificName: String
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case birdId, scientificName, image
    }
    var id: Int {
        birdId
    }
}

