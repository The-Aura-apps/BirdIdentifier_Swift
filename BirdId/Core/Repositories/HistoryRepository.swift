//
//  HistoryRepository.swift
//  BirdId
//
//  Created by ali bakhsha on 9/20/1404 AP.
//


import Foundation
import Combine
import Alamofire

protocol HistoryRepositoryProtocol {
    func fetchHistory() -> AnyPublisher<[HistorySimpleModel], Error>
}

class HistoryRepository: HistoryRepositoryProtocol {
    private let apiService: ApiServiceProtocol
    
    init(apiService: ApiServiceProtocol = ApiService()) {
        self.apiService = apiService
    }
    
    func fetchHistory() -> AnyPublisher<[HistorySimpleModel], Error> {
        // دریافت deviceId از DeviceIDManager
        let deviceId = DeviceIDManager.shared.getDeviceUUID()
        
        let url = "\(Constants.Urls.historySimple)\(deviceId)"
        
        return apiService.request(
            url,
            method: .get,
            body: nil,
            headers: nil,
            expecting: [HistorySimpleModel].self
        )
    }
}

// MARK: - Mock Repository for Testing
class MockHistoryRepository: HistoryRepositoryProtocol {
    var shouldFail = false
    var mockData: [HistorySimpleModel] = HistorySimpleModel.mockList
    var delaySeconds: TimeInterval = 1.0
    
    func fetchHistory() -> AnyPublisher<[HistorySimpleModel], Error> {
        if shouldFail {
            return Fail(error: APIError.networkError(underlyingError: URLError(.notConnectedToInternet)))
                .delay(for: .seconds(delaySeconds), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        return Just(mockData)
            .delay(for: .seconds(delaySeconds), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
