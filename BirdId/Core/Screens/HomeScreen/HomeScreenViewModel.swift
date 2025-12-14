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
    @Published var errorMessage:   String?
    
    // Search related properties
    @Published var searchResults: [BirdSearchItem] = []
    @Published var isSearching = false
    @Published var showSearchResults = false
    
    // Bird detail fetch - برای نمایش SearchResultScreen
    @Published var isLoadingBirdDetail = false
    @Published var showLoadingScreen = false
    
    private let habitatsRepository:  HabitatsRepositoryProtocol
    private let searchRepository:  BirdSearchRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?
    private weak var coordinator: Coordinator?
    
    init(
        habitatsRepository: HabitatsRepositoryProtocol = HabitatsRepository(),
        searchRepository: BirdSearchRepositoryProtocol = BirdSearchRepository()
    ) {
        self.habitatsRepository = habitatsRepository
        self.searchRepository = searchRepository
        fetchHabitats()
        setupSearchDebounce()
    }
    
    func setCoordinator(_ coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
    func fetchHabitats() {
        isLoadingHabitats = true
        errorMessage = nil
        
        habitatsRepository.getHabitats()
            .sink { [weak self] completion in
                self?.isLoadingHabitats = false
                if case .failure(let error) = completion {
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
    
    func fetchBirdDetail(scientificName: String) {
        showLoadingScreen = true
        isLoadingBirdDetail = true
        
        searchRepository.fetchBirdByScientificName(scientificName: scientificName)
            .sink { [weak self] result in
                self?.isLoadingBirdDetail = false
                if case .failure(let error) = result {
                    print("Error fetching bird detail: \(error.localizedDescription)")
                    self?.showLoadingScreen = false
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] birdDetail in
                guard let self = self else { return }
                
                let mockUploadResponse = UploadResponse(
                    success: true,
                    bird:  birdDetail,
                    confidence: "100%",
                    status: "success",
                    observation: ObservationInfo(
                        id: UUID().uuidString,
                        createdAt: ISO8601DateFormatter().string(from: Date())
                    )
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showLoadingScreen = false
                    self.clearSearch()
                    
                    self.coordinator?.push(.ResultScreen(uploadResponse: mockUploadResponse))
                }
            }
            .store(in: &cancellables)
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
