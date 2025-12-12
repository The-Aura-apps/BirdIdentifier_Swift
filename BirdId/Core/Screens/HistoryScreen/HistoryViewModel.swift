//
//  HistoryViewModel.swift
//  BirdId
//
//  Created by ali bakhsha on 9/20/1404 AP.
//
//
//  HistoryViewModel.swift
//  BirdId
//
//  Created by ali bakhsha on 9/20/1404 AP.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var birds: [HistorySimpleModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let repository: HistoryRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: HistoryRepositoryProtocol = HistoryRepository()) {
        self.repository = repository
    }
    
    func loadHistory() {
        isLoading = true
        errorMessage = nil
        showError = false
        
        repository.fetchHistory()
            .receive(on: DispatchQueue.main) // ✅ FIX: اطمینان از اجرا روی main thread
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                Task { @MainActor in
                    self.isLoading = false
                    
                    switch completion {
                    case .finished:
                        print("✅ History loaded successfully: \(self.birds.count) birds")
                    case .failure(let error):
                        print("❌ History load failed: \(error.localizedDescription)")
                        self.handleError(error)
                    }
                }
            } receiveValue: { [weak self] birds in
                guard let self = self else { return }
                
                Task { @MainActor in
                    print("📦 Received \(birds.count) birds from API")
                    self.birds = birds
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            switch apiError {
            case .httpError(let statusCode, _):
                errorMessage = "Server error (\(statusCode))"
            case .decodingError(let decodingError):
                // ✅ FIX: اطلاعات بیشتر برای debugging
                print("🔴 Decoding Error: \(decodingError)")
                errorMessage = "Failed to process data"
            case .networkError(let urlError):
                if urlError.code == .notConnectedToInternet {
                    errorMessage = "No internet connection"
                } else if urlError.code == .timedOut {
                    errorMessage = "Request timeout"
                } else {
                    errorMessage = "Network error occurred"
                }
            case .unknownError:
//                print("🔴 Unknown Error: \(underlyingError)")
                errorMessage = "An unexpected error occurred"
            }
        } else {
            print("🔴 General Error: \(error)")
            errorMessage = error.localizedDescription
        }
        showError = true
    }
    
    func retry() {
        loadHistory()
    }
}
