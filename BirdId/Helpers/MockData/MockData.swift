//
//  MockData.swift
//  BirdId
//
//  Created by ali bakhsha on 9/3/1404 AP.
//

import Foundation

// MARK: - Mock Data Extension
extension ObservationDetailResponse {
    static var mock: ObservationDetailResponse {
        ObservationDetailResponse(
            id: "27f36cb5-1e4e-4278-beb2-d2d53ec0f00e",
            deviceId: "11111",
            type: "image",
            status: .completed,
            uploadId: 1,
            birdId: 3,
            aiResult: AIResult(
                result: BirdDetail.mock,
                status: "identified",
                confidence: 0.9
            ),
            confidence: "0.9000",
            errorMessage: nil,
            createdAt: "2025-11-24T09:26:54.457Z",
            updatedAt: "2025-11-24T09:27:30.412Z",
            bird: Bird.mock
        )
    }
}

extension BirdDetail {
    static var mock: BirdDetail {
        BirdDetail(
            size: BirdSize(
                lengthCm: SizeRange(max: 30, min: 22),
                wingspanCm: SizeRange(max: 43, min: 34),
                weightGrams: SizeRange(max: 100, min: 70)
            ),
            behavior: "Blue jays are known for their intelligence and complex social behaviors.",
            habitats: ["Forest", "Grassland", "Scrub"],
            taxonomy: Taxonomy.mock,
            birdFoods: [
                BirdFood(name: "Seeds", description: "Various seeds including sunflower"),
                BirdFood(name: "Insects", description: "Caterpillars and beetles")
            ],
            coolFacts: [
                "Blue jays can mimic hawk calls",
                "They can recognize human faces"
            ],
            commonNames: [
                CommonName(name: "Blue Jay", region: "North America", language: "en")
            ],
            description: "A striking medium-sized bird with vibrant blue plumage.",
            distributions: [
                Distribution(
                    month: 1,
                    season: "non-breeding",
                    location: Location(
                        region: "Eastern regions",
                        country: "United States",
                        coordinates: Coordinates(lat: 39, lng: -95)
                    ),
                    countries: ["United States", "Canada"],
                    description: "Found in wooded areas",
                    presenceScore: 0.8
                )
            ],
            feedingHabits: "Omnivorous with diverse diet",
            nestingHabits: "Nests in trees using twigs and grass",
            scientificName: "Cyanocitta cristata",
            eggsDescription: "Pale blue eggs with brown speckles",
            conservationStatus: ConservationStatus.mock,
            lifeExpectancyYears: 7
        )
    }
}

extension Bird {
    static var mock: Bird {
        Bird(
            id: 3,
            scientificName: "Cyanocitta cristata",
            description: "Vibrant blue bird",
            behavior: "Intelligent and social",
            nestingHabits: "Tree nester",
            feedingHabits: "Omnivorous",
            eggsDescription: "Pale blue eggs",
            coolFacts: "Can mimic calls",
            size: BirdSize(
                lengthCm: SizeRange(max: 30, min: 22),
                wingspanCm: SizeRange(max: 43, min: 34),
                weightGrams: SizeRange(max: 100, min: 70)
            ),
            lifeExpectancyYears: "7.0",
            taxonomy: Taxonomy.mock,
            conservationStatus: ConservationStatus.mock,
            habitats: []
        )
    }
}

extension Taxonomy {
    static var mock: Taxonomy {
        Taxonomy(
            id: 3,
            phylum: "Chordata",
            class: "Aves",
            order: "Passeriformes",
            family: "Corvidae",
            genus: "Cyanocitta",
            createdAt: nil,
            updatedAt: nil
        )
    }
}

extension ConservationStatus {
    static var mock: ConservationStatus {
        ConservationStatus(
            id: 1,
            code: "LC",
            fullName: "Least Concern",
            authority: "IUCN",
            description: "Stable population",
            severityLevel: 3,
            createdAt: nil,
            updatedAt: nil
        )
    }
}
