//
//  Constants.swift
//  BirdId
//
//  Created by ali bakhsha on 9/2/1404 AP.
//

import Foundation
import SwiftUI

let baseUrl: String = "http://46.249.101.76:3000"

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
    }
}
