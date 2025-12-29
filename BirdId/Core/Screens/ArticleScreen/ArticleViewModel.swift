//
//  ArticleViewModel.swift
//  BirdId
//
//  Created by ali bakhsha on 8/30/1404 AP.
//

import Foundation
import Combine

class ArticleViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let repository: ArticleRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(repository: ArticleRepositoryProtocol = ArticleRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    func fetchArticles() {
        isLoading = true
        errorMessage = nil
        
        repository.fetchArticles()
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    print("✅ Articles fetched successfully")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ Failed to fetch articles: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] articles in
                guard let self = self else { return }
                self.articles = articles
                print("📦 Received \(articles.count) articles")
            }
            .store(in: &cancellables)
    }
    
    func getArticle(by id: String) -> Article? {
        return articles.first { $0.id == id }
    }
}
