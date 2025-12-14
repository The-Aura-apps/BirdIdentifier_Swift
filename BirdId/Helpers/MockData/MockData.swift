//
//  MockData.swift
//  BirdId
//
//  Created by ali bakhsha on 9/3/1404 AP.
//

import Foundation

// MARK: - Mock Extensions
extension BirdDetailResponse {
    static var mock: BirdDetailResponse {
        BirdDetailResponse(
            id: 14,
            scientificName: "Branta canadensis",
            description: "Branta canadensis, commonly known as the Canada Goose, is a large waterfowl characterized by its long neck, black head, and white chinstrap...",
            behavior: "Canada Geese are highly social birds, often seen in large flocks, especially during migration...",
            nestingHabits: "Nesting typically occurs from March to June, with females selecting sites near water sources...",
            feedingHabits: "Canada Geese are primarily herbivorous, feeding on a variety of grasses, grains, and aquatic plants...",
            eggsDescription: "The eggs of the Canada Goose are typically oval-shaped, measuring approximately 7.5 to 9.0 cm in length...",
            coolFacts: "Canada Geese are known for their impressive migratory patterns...\n\nThey have a unique adaptation of flying in a V-formation...",
            lifeExpectancyYears: "10.0",
            size: Size(
                lengthCm: RangeValue(max: 110, min: 75),
                wingspanCm: RangeValue(max: 185, min: 150),
                weightGrams: RangeValue(max: 6000, min: 2500)
            ),
            commonNames: [
                CommonName(id: 39, name: "Canada Goose", language: "en", region: "North America", createdAt: "", updatedAt: ""),
                CommonName(id: 40, name: "Bernache du Canada", language: "fr", region: "Canada", createdAt: "", updatedAt: ""),
                CommonName(id: 41, name: "Ganso canadiense", language: "es", region: "Mexico", createdAt: "", updatedAt: "")
            ],
            taxonomy: Taxonomy(
                id: 12,
                phylum: "Chordata",
                class: "Aves",
                order: "Anseriformes",
                family: "Anatidae",
                genus: "Branta",
                createdAt: "",
                updatedAt: ""
            ),
            conservationStatus: ConservationStatus(
                id: 1,
                code: "LC",
                fullName: "Least Concern",
                description: "The Greater Flamingo is currently classified as Least Concern due to its wide distribution and stable populations...",
                severityLevel: 3,
                authority: "IUCN",
                createdAt: "",
                updatedAt: ""
            ),
            habitats: [
                BirdHabitat(id: 1, name: "Wetlands", description: "Wetland habitats include marshes, swamps, and bogs."),
                BirdHabitat(id: 2, name: "Grasslands", description: "Open grassland areas with scattered trees.")
            ],
            birdFoods: [
                BirdFoodWrapper(id: 25, isActive: true, createdAt: "", updatedAt: "",
                               food: Food(id: 15, name: "Aquatic Plants", description: "They forage on submerged and emergent aquatic vegetation...", imageStorageKey: nil)),
                BirdFoodWrapper(id: 23, isActive: true, createdAt: "", updatedAt: "",
                               food: Food(id: 14, name: "Grasses", description: "Canada Geese primarily feed on various species of grasses...", imageStorageKey: nil)),
                BirdFoodWrapper(id: 24, isActive: true, createdAt: "", updatedAt: "",
                               food: Food(id: 10, name: "Grains", description: "Commonly feed on grains like corn, wheat, and rice...", imageStorageKey: nil))
            ],
            distributions: [
                Distribution(
                    id: 55,
                    month: 4,
                    season: "breeding",
                    location: Location(region: "Northern provinces", country: "Canada",
                                     coordinates: Coordinates(lat: 60, lng: -95)),
                    presenceScore: 0.9,
                    description: "In April, Canada Geese return to their breeding grounds in Canada...",
                    countries: ["Canada", "United States"],
                    createdAt: "",
                    updatedAt: ""
                ),
                Distribution(
                    id: 56,
                    month: 8,
                    season: "migration",
                    location: Location(region: "Midwestern states", country: "United States",
                                     coordinates: Coordinates(lat: 40, lng: -100)),
                    presenceScore: 0.7,
                    description: "During August, Canada Geese begin their migration south...",
                    countries: ["United States", "Canada"],
                    createdAt: "",
                    updatedAt: ""
                )
            ],
            media: [
                Media(
                    id: 11,
                    storageKey: "https://upload.wikimedia.org/wikipedia/commons/7/74/Canadagoose.jpg",
                    type: "photo",
                    size: nil,
                    caption: "Canadagoose.jpg",
                    source: "wikimedia",
                    attribution: "Karrackoo - CC BY-SA 3.0",
                    orderIndex: 0,
                    metadata: MediaMetadata(thumbnailKey: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Canadagoose.jpg/960px-Canadagoose.jpg"),
                    createdAt: "",
                    updatedAt: ""
                )
            ]
        )
    }
}

// MARK: - UploadResponse Mock
extension UploadResponse {
    static var mock: UploadResponse {
        UploadResponse(
            success: true,
            bird: BirdDetailResponse.mock,
            confidence: "0.9200",
            status: "completed",
            observation: ObservationInfo(
                id: "test-observation-id-123",
                createdAt: "2025-12-10T10:00:00.000Z"
            )
        )
    }
    
    static var mockProcessing: UploadResponse {
        UploadResponse(
            success: true,
            bird: BirdDetailResponse.mock,
            confidence: "0.0000",
            status: "processing",
            observation: ObservationInfo(
                id: "test-observation-id-456",
                createdAt: "2025-12-10T10:00:00.000Z"
            )
        )
    }
    
    static var mockFailed: UploadResponse {
        UploadResponse(
            success: false,
            bird: BirdDetailResponse.mock,
            confidence: "0.0000",
            status: "failed",
            observation: ObservationInfo(
                id: "test-observation-id-789",
                createdAt: "2025-12-10T10:00:00.000Z"
            )
        )
    }
}
