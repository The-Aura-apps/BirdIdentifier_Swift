//
//  HistorySimpleModel.swift
//  BirdId
//
//  Created by ali bakhsha on 9/20/1404 AP.
//

import Foundation

struct HistorySimpleModel: Codable, Identifiable, Equatable {
    let birdId: Int
    let scientificName: String
//    let commonName: String
    let image: String
    
    var id: Int {
        birdId
    }
    
    enum CodingKeys: String, CodingKey {
        case birdId
        case scientificName
//        case commonName
        case image
    }
    
    static func == (lhs: HistorySimpleModel, rhs: HistorySimpleModel) -> Bool {
        lhs.birdId == rhs.birdId &&
        lhs.scientificName == rhs.scientificName 
//        lhs.commonName == rhs.commonName
    }
}

// MARK: - Mock Data for Preview
extension HistorySimpleModel {
    static let mock = HistorySimpleModel(
        birdId: 3,
        scientificName: "Cyanocitta cristata",
//        commonName: "Eastern Blue Jay",
        image: "http://46.249.101.76:3000/uploads/https://upload.wikimedia.org/wikipedia/commons/0/04/Cyanocitta-cristata-004.jpg"
    )
    
    static let mockList: [HistorySimpleModel] = [
        .mock,
        HistorySimpleModel(
            birdId: 2,
            scientificName: "Icterus galbula",
//            commonName: "Baltimore Oriole",
            image: "http://46.249.101.76:3000/uploads/https://upload.wikimedia.org/wikipedia/commons/6/66/Icterus-galbula-002.jpg"
        ),
        HistorySimpleModel(
            birdId: 1,
            scientificName: "Cardinalis cardinalis",
//            commonName: "Northern Cardinal",
            image: "http://46.249.101.76:3000/uploads/cardinal.jpg"
        )
    ]
}
