//
//  Constants.swift
//  BirdId
//
//  Created by ali bakhsha on 9/2/1404 AP.
//

import Foundation
import SwiftUI

let baseUrl: String = "http://185.125.103.136"

struct Constants{
    
    
    //MARK: URLs
    struct Urls {
        
        //upload
        static let uploads = "\(baseUrl)/uploads"
        
        //habitats
        static let habitats = "\(baseUrl)/habitats"
        
        //history
        static let historySimple = "\(baseUrl)/observations/history-unique/"
        
        
        static let birdDetail = "\(baseUrl)/birds/"
        static let birdHabitat = "\(baseUrl)/birds/by-habitat-simple/"
        static let birdSearch = "\(baseUrl)/birds/catalog/search"
        static let birdSearchFetch = "\(baseUrl)/birds/catalog/fetch/"
        static let birdFilterByHabitat = "\(baseUrl)/birds/filter-by-habitat"
        
        //device settings
        static let deviceSettings = "\(baseUrl)/device-settings"
        
        //articles
        static let articles = "\(baseUrl)/articles"
    }
}
