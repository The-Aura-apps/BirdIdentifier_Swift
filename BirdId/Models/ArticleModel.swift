//
//  ArticleModel.swift
//  BirdId
//
//  Created by ali bakhsha on 10/8/1404 AP.
//

import Foundation

// MARK: - Article Model
struct Article: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let photoUrl: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case photoUrl
        case createdAt
        case updatedAt
    }
    
    // Computed property for reading time (based on average reading speed of 200 words/min)
    var readingTime: String {
        let wordCount = content.split(separator: " ").count
        let minutes = max(1, wordCount / 200)
        return "\(minutes)m"
    }
    
    // Computed property for formatted date
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: createdAt) else {
            return "Unknown date"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMMM yyyy"
        return displayFormatter.string(from: date)
    }
}

// MARK: - Articles Response (Array)
typealias ArticlesResponse = [Article]
