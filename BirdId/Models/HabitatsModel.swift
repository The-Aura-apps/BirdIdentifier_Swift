//
//  HabitatsModel.swift
//  BirdId
//
//  Created by ali bakhsha on 9/19/1404 AP.
//

import Foundation

// MARK: - Habitat Model
struct HabitatsModel: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String?
}

// MARK: - Habitats Response
struct HabitatsResponse: Codable {
    let data: [HabitatsModel]
    let total: Int
}
