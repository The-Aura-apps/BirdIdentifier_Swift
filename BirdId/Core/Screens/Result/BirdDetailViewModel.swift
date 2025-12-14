//
//  BirdDetailViewModel.swift
//  BirdId
//
//  Created by ali bakhsha on 9/21/1404 AP.
//

import Foundation
import Combine

class BirdDetailViewModel: ObservableObject {
    @Published var birdDetail: BirdDetailResponse?
    @Published var isLoading:  Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String?
    
    private let repository: BirdDetailRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: BirdDetailRepositoryProtocol = BirdDetailRepository()) {
        self.repository = repository
    }
    
    func fetchBirdDetail(id: Int) {
        isLoading = true
        
        repository.fetchBirdDetail(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            } receiveValue: { [weak self] birdDetail in
                self?.birdDetail = birdDetail
            }
            .store(in: &cancellables)
    }
    
    func retry(id: Int) {
        fetchBirdDetail(id: id)
    }
}
