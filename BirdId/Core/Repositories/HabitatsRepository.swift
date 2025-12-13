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
    func getHabitatDetail(id: Int) -> AnyPublisher<HabitatDetailResponse, Error>
    func getHabitatBird(id: Int) -> AnyPublisher<[BirdHabitatSimple], Error>
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
    
    func getHabitatBird(id: Int) -> AnyPublisher<[BirdHabitatSimple], Error> {
        return apiService.request(
            "\(Constants.Urls.birdHabitat)\(id)",
            method: .get,
            body: nil,
            headers: nil,
            expecting: [BirdHabitatSimple].self
        )
    }
    
    func getHabitatDetail(id: Int) -> AnyPublisher<HabitatDetailResponse, Error> {
        return apiService.request(
            "\(Constants.Urls.habitats)/\(id)",
            method: .get,
            body: nil,
            headers: nil,
            expecting: HabitatDetailResponse.self
        )
    }
}
