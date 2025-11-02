//
//  GlassEffect.swift
//  BirdId
//
//  Created by ali bakhsha on 7/23/1404 AP.
//

import Foundation
import SwiftUI

enum GlassStyle {
    case regular
    case clear
    case identity
}

extension View {
    @ViewBuilder
    func adaptiveGlassEffect(style: GlassStyle? = nil, cornerRadius: CGFloat = 24) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        
        if #available(iOS 26.0, *) {
            if let style = style {
                switch style {
                case .regular:
                    self.glassEffect(.regular, in: shape)
                case .clear:
                    self.glassEffect(.clear, in: shape)
                case .identity:
                    self.glassEffect(.identity, in: shape)
                }
            } else {
                self.glassEffect(.regular, in: shape)
            }
        } else {
            if let style = style {
                switch style {
                case .regular:
                    self.background(.ultraThickMaterial.opacity(0.1),in: shape)
                case .clear:
                    self.background(.ultraThinMaterial,in: shape)
                default: self.background(.ultraThinMaterial,in: shape)
                }
            } else {
                self.background(.ultraThinMaterial,in: shape)
            }
        }
    }
}
