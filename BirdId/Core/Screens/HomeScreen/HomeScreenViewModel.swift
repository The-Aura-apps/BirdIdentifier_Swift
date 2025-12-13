//
//  HomeViewModel.swift
//  BirdId
//
//  Created by ali bakhsha on 7/22/1404 AP.
//


import Foundation
import Combine
import SwiftUI

@MainActor
class HomeScreenViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var habitats: [HabitatsModel] = []
    @Published var isLoadingHabitats = false
    @Published var errorMessage:  String?
    
    // Search related properties
    @Published var searchResults: [BirdSearchItem] = []
    @Published var isSearching = false
    @Published var showSearchResults = false
    
    private let habitatsRepository:  HabitatsRepositoryProtocol
    private let searchRepository:  BirdSearchRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?
    
    init(
        habitatsRepository: HabitatsRepositoryProtocol = HabitatsRepository(),
        searchRepository: BirdSearchRepositoryProtocol = BirdSearchRepository()
    ) {
        self.habitatsRepository = habitatsRepository
        self.searchRepository = searchRepository
        fetchHabitats()
        setupSearchDebounce()
    }
    
    func fetchHabitats() {
        isLoadingHabitats = true
        errorMessage = nil
        
        habitatsRepository.getHabitats()
            .sink { [weak self] completion in
                self?.isLoadingHabitats = false
                if case . failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Error fetching habitats:  \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] response in
                self?.habitats = response.data
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchQuery in
                self?.performSearch(query: searchQuery)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        // Cancel previous search
        searchCancellable?.cancel()
        
        // Clear results if query is less than 3 characters
        guard query.count >= 3 else {
            searchResults = []
            showSearchResults = false
            isSearching = false
            return
        }
        
        isSearching = true
        showSearchResults = true
        
        searchCancellable = searchRepository.searchBirds(query: query)
            .sink { [weak self] completion in
                self?.isSearching = false
                if case .failure(let error) = completion {
                    print("Search error: \(error.localizedDescription)")
                    self?.searchResults = []
                }
            } receiveValue:  { [weak self] results in
                self?.searchResults = results
                self?.isSearching = false
            }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        showSearchResults = false
        isSearching = false
    }
    
    func getHabitatImage(for habitatName: String) -> ImageResource {
        switch habitatName.lowercased() {
        case "desert":
            return . desert
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
