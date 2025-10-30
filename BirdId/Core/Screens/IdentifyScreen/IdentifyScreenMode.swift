//
//  IdentifyScreenMode.swift
//  BirdId
//
//  Created by ali bakhsha on 8/6/1404 AP.
//

import Foundation
import SwiftUI

enum IdentificationMode: CaseIterable {
    case camera
    case mic
    case gallery
    
    var title: String {
        switch self {
        case .camera: return "Identify a bird via photo"
        case .mic: return "Identify a bird via sound"
        case .gallery: return "Identify a bird from gallery"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        default: return Color(hex: "#5B765C")
        }
    }
    
    var centerButtonIcon: Image {
        switch self {
        case .camera: return Image(.camera)
        case .mic: return Image(.microphone)
        case .gallery: return Image(.galleryAdd)
        }
    }
    
    var centerButtonAction: String {
        switch self {
        case .camera: return "capture"
        case .mic: return "record"
        case .gallery: return "select"
        }
    }
}
