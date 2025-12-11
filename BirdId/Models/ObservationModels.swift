////
////  ObservationModels.swift
////  BirdId
////
////  Created by ali bakhsha on 9/3/1404 AP.
////
//
//import Foundation
//
//// MARK: - Observation Detail Response
//struct ObservationDetailResponse: Decodable {
//    let id: String
//    let deviceId: String
//    let type: String
//    let status: ObservationStatus
//    let uploadId: Int
//    let birdId: Int?
//    let aiResult: AIResult?
//    let confidence: String?
//    let errorMessage: String?
//    let createdAt: String
//    let updatedAt: String
//    let bird: Bird?
//}
//
//// MARK: - Observation Status
//enum ObservationStatus: String, Decodable {
//    case processing = "processing"
//    case completed = "completed"
//    case failed = "failed"
//    case pending = "pending"
//}
//
//// MARK: - AI Result
//struct AIResult: Decodable {
//    let result: BirdDetail
//    let status: String
//    let confidence: Double
//}
//
//// MARK: - Bird Detail
//struct BirdDetail: Decodable {
//    let size: BirdSize
//    let behavior: String
//    let habitats: [String]
//    let taxonomy: Taxonomy
//    let birdFoods: [BirdFood]
//    let coolFacts: [String]
//    let commonNames: [CommonName]
//    let description: String
//    let distributions: [Distribution]
//    let feedingHabits: String
//    let nestingHabits: String
//    let scientificName: String
//    let eggsDescription: String
//    let conservationStatus: ConservationStatus
//    let lifeExpectancyYears: Int
//}
//
//// MARK: - Bird Size
//struct BirdSize: Decodable {
//    let lengthCm: SizeRange
//    let wingspanCm: SizeRange
//    let weightGrams: SizeRange
//}
//
//struct SizeRange: Decodable {
//    let max: Double
//    let min: Double
//}
//
//// MARK: - Taxonomy
//struct Taxonomy: Decodable {
//    let id: Int?
//    let phylum: String
//    let `class`: String
//    let order: String
//    let family: String
//    let genus: String
//    let createdAt: String?
//    let updatedAt: String?
//}
//
//// MARK: - Bird Food
//struct BirdFood: Decodable {
//    let name: String
//    let description: String
//}
//
//// MARK: - Common Name
//struct CommonName: Decodable {
//    let name: String
//    let region: String
//    let language: String
//}
//
//// MARK: - Distribution
//struct Distribution: Decodable {
//    let month: Int
//    let season: String
//    let location: Location
//    let countries: [String]
//    let description: String
//    let presenceScore: Double
//}
//
//struct Location: Decodable {
//    let region: String
//    let country: String
//    let coordinates: Coordinates
//}
//
//struct Coordinates: Decodable {
//    let lat: Double
//    let lng: Double
//}
//
//// MARK: - Conservation Status
//struct ConservationStatus: Decodable {
//    let id: Int?
//    let code: String
//    let fullName: String
//    let authority: String
//    let description: String
//    let severityLevel: Int
//    let createdAt: String?
//    let updatedAt: String?
//}
//
//// MARK: - Bird (Summary)
//struct Bird: Decodable {
//    let id: Int
//    let scientificName: String
//    let description: String
//    let behavior: String
//    let nestingHabits: String
//    let feedingHabits: String
//    let eggsDescription: String
//    let coolFacts: String
//    let size: BirdSize
//    let lifeExpectancyYears: String
//    let taxonomy: Taxonomy
//    let conservationStatus: ConservationStatus
//    let habitats: [String]
//}
