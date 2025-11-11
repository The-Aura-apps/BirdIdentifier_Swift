//
//  IosVersion.swift
//  BirdId
//
//  Created by ali bakhsha on 8/14/1404 AP.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func ifAvailable(_ apply: (Self) -> some View) -> some View {
        if #available(iOS 26.0, *) {
            apply(self)
        } else {
            self
        }
    }
}
