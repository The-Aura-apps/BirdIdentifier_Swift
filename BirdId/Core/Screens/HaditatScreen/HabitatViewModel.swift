//
//  HabitatViewModel.swift
//  BirdId
//
//  Created by ali bakhsha on 8/30/1404 AP.
//

import Foundation
import Combine

class HabitatViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var birds: [BirdHabitatSimple] = []
    @Published var isLoading = false
    @Published var errorMessage:  String?
    
    private let repository: HabitatsRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: HabitatsRepositoryProtocol = HabitatsRepository()) {
        self.repository = repository
    }
    
    // Filtered birds based on search
    var filteredBirds: [BirdHabitatSimple] {
        if searchText.isEmpty {
            return birds
        }
        
        return birds.filter { bird in
            bird.scientificName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func loadHabitatBirds(id: Int) {
        isLoading = true
        errorMessage = nil
        
        repository.getHabitatBird(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case . finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error loading habitat birds: \(error)")
                }
            } receiveValue: { [weak self] response in
                self?.birds = response
            }
            .store(in: &cancellables)
    }
}
