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

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreen {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    rootContent
                        .transition(.opacity)
                }
            }
        }
    }

    @ViewBuilder
    private var rootContent: some View {
        if hasSeenOnboarding {
            MainScreen()
                .environmentObject(coordinator)
                .environmentObject(tabManager)
        } else {
            OnboardingScreen()
        }
    }
}
