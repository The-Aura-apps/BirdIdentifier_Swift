//
//  BirdDetailRepository.swift
//  BirdId
//
//  Created by ali bakhsha on 9/21/1404 AP.
//

import Foundation
import Combine
import Alamofire

protocol BirdDetailRepositoryProtocol {
    func fetchBirdDetail(id: Int) -> AnyPublisher<BirdDetailResponse, Error>
}

class BirdDetailRepository: BirdDetailRepositoryProtocol {
    private let apiService: ApiServiceProtocol
    
    init(apiService: ApiServiceProtocol = ApiService()) {
        self.apiService = apiService
    }
    
    func fetchBirdDetail(id: Int) -> AnyPublisher<BirdDetailResponse, Error> {
        let url = "\(Constants.Urls.birdDetail)\(id)"
        
        return apiService.request(
            url,
            method: .get,
            body: nil,
            headers: nil,
            expecting: BirdDetailResponse.self
        )
    }
}

// MARK: - Mock Repository for Testing
class MockBirdDetailRepository:  BirdDetailRepositoryProtocol {
    var shouldFail = false
    var mockData: BirdDetailResponse = . mock
    var delaySeconds:  TimeInterval = 1.0
    
    func fetchBirdDetail(id: Int) -> AnyPublisher<BirdDetailResponse, Error> {
        if shouldFail {
            return Fail(error: APIError.networkError(underlyingError: URLError(.notConnectedToInternet)))
                .delay(for: . seconds(delaySeconds), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        return Just(mockData)
            .delay(for: .seconds(delaySeconds), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
