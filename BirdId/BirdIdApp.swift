//
//  BirdIdApp.swift
//  BirdId
//
//  Created by ali bakhsha on 7/9/1404 AP.
//

import SwiftUI

@main
struct BirdIdApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @StateObject var coordinator = Coordinator()
    @StateObject private var tabManager = TabManager()
    
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainScreen()
                    .environmentObject(coordinator)
                    .environmentObject(tabManager)
            } else {
                OnboardingScreen()
            }
        }
    }
}
