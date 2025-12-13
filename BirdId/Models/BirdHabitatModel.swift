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
    let image: String
    
    var id: Int {
        birdId
    }
    
    // Helper computed property to get image URL
    var imageURL: URL? {
        URL(string:  image)
    }
}

