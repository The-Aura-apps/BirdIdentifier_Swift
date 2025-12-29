//
//  ArticleRepository.swift
//  BirdId
//
//  Created by ali bakhsha on 10/8/1404 AP.
//

import Foundation
import Combine
import Alamofire

protocol ArticleRepositoryProtocol {
    func fetchArticles() -> AnyPublisher<ArticlesResponse, Error>
}

class ArticleRepository: ArticleRepositoryProtocol {
    
    private let apiService: ApiServiceProtocol
    
    init(apiService: ApiServiceProtocol = ApiService()) {
        self.apiService = apiService
    }
    
    func fetchArticles() -> AnyPublisher<ArticlesResponse, Error> {
        return apiService.request(
            Constants.Urls.articles,
            method: .get,
            body: nil,
            headers: nil,
            expecting: ArticlesResponse.self
        )
    }
}
