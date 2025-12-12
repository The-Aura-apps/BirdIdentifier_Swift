//
//  HabitatsRepository.swift
//  BirdId
//
//  Created by ali bakhsha on 9/19/1404 AP.
//

import Foundation
import Combine
import Alamofire

protocol HabitatsRepositoryProtocol {
    func getHabitats() -> AnyPublisher<HabitatsResponse, Error>
}

class HabitatsRepository: HabitatsRepositoryProtocol {
    
    private let apiService: ApiServiceProtocol
    
    init(apiService: ApiServiceProtocol = ApiService()) {
        self.apiService = apiService
    }
    
    func getHabitats() -> AnyPublisher<HabitatsResponse, Error> {
        return apiService.request(
            Constants.Urls.habitats,
            method: .get,
            body: nil,
            headers: nil,
            expecting: HabitatsResponse.self
        )
    }
}
