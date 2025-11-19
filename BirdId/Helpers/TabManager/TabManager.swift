//
//  TabManager.swift
//  BirdId
//
//  Created by ali bakhsha on 8/28/1404 AP.
//

import Foundation
import SwiftUI
import Combine

class TabManager: ObservableObject {
    @Published var selectedTab: TabBarItem = .home
}
