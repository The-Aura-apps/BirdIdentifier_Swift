//
//  Font+Extension.swift
//  BirdId
//
//  Created by ali bakhsha on 7/12/1404 AP.
//

import Foundation
import SwiftUI

enum AppFont {
    case Headline1
    case Headline2
    case Headline3
    

    case Sub1
    case Sub2
    case Micro1
}


extension Font {
    static func app(_ style: AppFont) -> Font {
        switch style {
        case .Headline1:
            return .system(size: 24, weight: .bold, design: .default)
        case .Headline2:
            return .system(size: 20, weight: .bold, design: .default)
        case .Headline3:
            return .system(size: 20, weight: .regular, design: .default)
        case .Sub1:
            return .system(size: 16, weight: .regular, design: .default)
        case .Sub2:
            return .system(size: 14, weight: .regular, design: .default)
        case .Micro1:
            return .system(size: 12, weight: .regular, design: .default)

        }		
    }
}
