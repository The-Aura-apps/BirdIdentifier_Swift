//
//  Font+Extension.swift
//  BirdId
//
//  Created by ali bakhsha on 7/12/1404 AP.
//

import Foundation
import SwiftUI

enum AppFont {
    case Title1
    
    
    case Headline1
    case Headline2
    case Headline3
    case Headline4
    

    case Sub1
    case Sub2
    case Micro1
    case Micro2
}


extension Font {
    static func app(_ style: AppFont) -> Font {
        switch style {
        case .Title1:
            return .system(size: 32, weight: .bold, design: .default)
        case .Headline1:
            return .system(size: 24, weight: .bold, design: .default)
        case .Headline2:
            return .system(size: 20, weight: .bold, design: .default)
        case .Headline3:
            return .system(size: 20, weight: .regular, design: .default)
        case .Headline4:
            return .system(size: 16, weight: .semibold, design: .default)
        case .Sub1:
            return .system(size: 16, weight: .regular, design: .default)
        case .Sub2:
            return .system(size: 14, weight: .regular, design: .default)
        case .Micro1:
            return .system(size: 12, weight: .regular, design: .default)
        case .Micro2:
            return .system(size: 12, weight: .semibold, design: .default)

        }		
    }
}
