//
//  GlassEffect.swift
//  BirdId
//
//  Created by ali bakhsha on 7/23/1404 AP.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func adaptiveGlassEffect(_ style: Glass, cornerRadius: CGFloat = 24) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(style, in: RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            self.background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}
