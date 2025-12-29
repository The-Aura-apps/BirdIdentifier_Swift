//
//  ShimmerEffect.swift
//  BirdId
//
//  Created by ali bakhsha on 10/8/1404 AP.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func shimmering(active: Bool = true) -> some View {
        if active {
            self.overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: -200)
            )
        } else {
            self
        }
    }
}
