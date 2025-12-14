//
//  BirdSearchModel.swift
//  BirdId
//
//  Created by ali bakhsha on 9/22/1404 AP.
//

import Foundation

// MARK: - Bird Search Response
struct BirdSearchItem: Decodable, Identifiable {
    let scientificName: String
    let englishName: String
    
    var id: String { scientificName }
    
    enum CodingKeys: String, CodingKey {
        case scientificName
        case englishName
    }
}

typealias BirdSearchResponse = [BirdSearchItem]
