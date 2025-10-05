//
//  OnboardingData.swift
//  BirdId
//
//  Created by ali bakhsha on 7/9/1404 AP.
//

import Foundation
import SwiftUI

enum OnboardingData: Int,CaseIterable,Identifiable {
    
    case firstPage = 1
    case secondPage = 2
    case thirdPage = 3
    case forthPage = 4
    
    
    var id: Int {
        switch self {
        case .firstPage:
            return 1
        case .secondPage:
            return 2
        case .thirdPage:
            return 3
        case .forthPage:
            return 4
        }
    }
    
   var backgroundImage: Image {
       switch self {
       default: Image(.onboardingBgImg)
               .resizable()
       }
    }
    
   var image: Image? {
       switch self {
       case .firstPage,.forthPage: return Image(.onboardingLogo)
               .resizable()
       default: return nil
       }
    }
    
    
    var questions: String {
        switch self {
        case .secondPage:
            return "How would you like to identify \nbirds?"
        case .thirdPage:
            return  "What brings you here?"
        default: return ""
        }
    }
    
    var answer : [(Image?,String)] {
            switch self {
                
            case .firstPage:
                return []
            case .secondPage:
                return [(Image(.camera),"By Photo") , (Image(.microphone),"By Sound") , (nil,"Photo & Sound ") ]
            case .thirdPage:
                return [(Image(.confettiMinimalistic),"For Fun") , (Image(.fireMinimalistic),"Hunting") , (Image(.mdiBird),"Keeping Birds"),   (Image(.starCircle),"Just Interested"), ]
            case .forthPage:
                return []
            }
            
        }
    
    var mainText: String {
        switch self {
        case .firstPage:
            return "Welcome!"
        case .forthPage:
            return "We’re personalizing your experience"
        default: return ""
        }
    }    
    
    var secondaryText: String {
        switch self {
        case .firstPage:
            return "Discover Birds Around You"
        default: return ""
        }
    }    
    
    var bodyText: String {
        switch self {
        case .firstPage:
            return "Identify birds by photo or sound.\n Explore nature in a whole new way."
        case .forthPage:
            return "Based on your answers, we’re shaping the app just for you."
        default: return ""
        }
    }
    
    
    func next() -> Self {
        let all = Self.allCases
        guard let currentIndex = all.firstIndex(of: self) else { return self }
        let nextIndex = all.index(after: currentIndex)
        return all[nextIndex == all.endIndex ? currentIndex : nextIndex]
    }
    
    func back() -> Self {
        let all = Self.allCases
        guard let currentIndex = all.firstIndex(of: self) else { return self }
        let prevIndex = all.index(before: currentIndex)
        return currentIndex == all.startIndex ? self : all[prevIndex]
    }
    
    
}
