//
//  HomeViewModel.swift
//  BirdId
//
//  Created by ali bakhsha on 7/22/1404 AP.
//


import Foundation
import Combine
import SwiftUI

class HomeScreenViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var habitats: [HabitatsModel] = []
    @Published var isLoadingHabitats = false
    @Published var errorMessage: String?
    
    private let habitatsRepository: HabitatsRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(habitatsRepository: HabitatsRepositoryProtocol = HabitatsRepository()) {
        self.habitatsRepository = habitatsRepository
        fetchHabitats()
    }
    
    func fetchHabitats() {
        isLoadingHabitats = true
        errorMessage = nil
        
        habitatsRepository.getHabitats()
            .sink { [weak self] completion in
                self?.isLoadingHabitats = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Error fetching habitats: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] response in
                self?.habitats = response.data
            }
            .store(in: &cancellables)
    }
    
    func getHabitatImage(for habitatName: String) -> ImageResource {
        switch habitatName.lowercased() {
        case "desert":
            return .desert
        case "forest":
            return .forest
        case "grassland":
            return .grassland
        case "marine":
            return .marine
        case "savanna":
            return .savanna
        case "scrub":
            return .scrub
        case "subterranean":
            return .subterranean
        case "wetlands":
            return .wetlands
        default:
            return .desert // default image
        }
    }
}
