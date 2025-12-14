//
//  BirdFilterModel.swift
//  BirdId
//
//  Created by ali bakhsha on 9/22/1404 AP.
//

//
//  BirdHabitatModel.swift
//  BirdId
//
//  Created by ali bakhsha on 9/22/1404 AP.
//

import Foundation

struct BirdFilterResponse: Decodable {
    let data: [BirdDetailResponse]
    let total: Int
    let habitat: String
}

