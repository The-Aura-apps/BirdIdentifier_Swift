//
//  BirdSearchRepository.swift
//  BirdId
//
//  Created by ali bakhsha on 9/22/1404 AP.
//

import Foundation
import Combine
import Alamofire

protocol BirdSearchRepositoryProtocol {
    func searchBirds(query: String) -> AnyPublisher<BirdSearchResponse, Error>
    func fetchBirdByScientificName(scientificName: String) -> AnyPublisher<BirdDetailResponse, Error>
}

class BirdSearchRepository: BirdSearchRepositoryProtocol {
    private let apiService: ApiServiceProtocol
    
    init(apiService: ApiServiceProtocol = ApiService()) {
        self.apiService = apiService
    }
    
    func searchBirds(query: String) -> AnyPublisher<BirdSearchResponse, Error> {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = "\(Constants.Urls.birdSearch)?q=\(encodedQuery)"
        
        return apiService.request(
            url,
            method: .get,
            body: nil,
            headers: nil,
            expecting: BirdSearchResponse.self
        )
    }
    
    func fetchBirdByScientificName(scientificName: String) -> AnyPublisher<BirdDetailResponse, Error> {
        let encodedName = scientificName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? scientificName
        let url = "\(Constants.Urls.birdSearchFetch)\(encodedName)"
        
        return apiService.request(
            url,
            method: . get,
            body: nil,
            headers: nil,
            expecting: BirdDetailResponse.self
        )
    }
}
