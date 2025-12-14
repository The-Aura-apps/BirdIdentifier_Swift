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
    @Published var birds:  [BirdHabitatSimple] = []
    @Published var filteredBirdsDetail:  [BirdDetailResponse] = []
    @Published var isLoading = false
    @Published var isSearching = false
    @Published var errorMessage: String?
    
    private let repository: HabitatsRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?
    private var currentHabitatId: Int?
    
    init(repository: HabitatsRepositoryProtocol = HabitatsRepository()) {
        self.repository = repository
        setupSearchDebounce()
    }
    
    // 👇 Setup debounce برای سرچ
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    // Filtered birds - اگر جستجو فعال باشد از API، وگرنه لیست اصلی
    var filteredBirds: [BirdHabitatSimple] {
        if searchText.isEmpty {
            return birds
        }
        return []
    }
    
    func loadHabitatBirds(id: Int) {
        print("🔍 Loading habitat birds for ID: \(id)")
        currentHabitatId = id
        isLoading = true
        errorMessage = nil
        birds = []
        filteredBirdsDetail = []
        
        repository.getHabitatBird(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .finished:
                    print("✅ Successfully loaded habitat birds")
                case . failure(let error):
                    let errorMsg = error.localizedDescription
                    self?.errorMessage = errorMsg
                    print("❌ Error loading habitat birds: \(errorMsg)")
                    
                    if let apiError = error as? APIError {
                        print("📛 API Error Details:")
                        print("   - Description: \(apiError.errorDescription ??  "N/A")")
                        print("   - Code: \(apiError.errorCode ??  -1)")
                    }
                }
            } receiveValue: { [weak self] response in
                print("📦 Received \(response.count) birds")
                self?.birds = response
                
                response.prefix(3).forEach { bird in
                    print("   🐦 \(bird.scientificName) - ID: \(bird.birdId)")
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        guard let habitatId = currentHabitatId else { return }
        
        searchCancellable?.cancel()
        
        guard !query.isEmpty else {
            filteredBirdsDetail = []
            isSearching = false
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        print("🔎 Searching for: '\(query)' in habitat:  \(habitatId)")
        
        searchCancellable = repository.filterBirdsByHabitat(habitatId: habitatId, search: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSearching = false
                
                switch completion {
                case . finished:
                    print("✅ Search completed successfully")
                case .failure(let error):
                    print("❌ Search error: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    self?.filteredBirdsDetail = []
                }
            } receiveValue: { [weak self] response in
                print("📦 Search found \(response.total) birds")
                self?.filteredBirdsDetail = response.data
                
                response.data.prefix(3).forEach { bird in
                    print("   🐦 \(bird.scientificName) - ID: \(bird.id)")
                }
            }
    }
    
    func clearSearch() {
        searchText = ""
        filteredBirdsDetail = []
        isSearching = false
        errorMessage = nil
    }
}
