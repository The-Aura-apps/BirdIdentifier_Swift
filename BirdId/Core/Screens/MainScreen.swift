//
//  MainScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 7/18/1404 AP.
//

import SwiftUI

struct MainScreen: View {
//    @State private var selectedTab: TabBarItem = .home
    @EnvironmentObject var tabManager: TabManager
    @State private var currentMode: IdentificationMode = .camera
    @EnvironmentObject var coordinator : Coordinator

    @StateObject private var homeViewModel = HomeScreenViewModel()

    // Show the paywall once, right after onboarding, for non-premium users.
    @AppStorage("hasSeenPostOnboardingPaywall") private var hasSeenPostOnboardingPaywall = false
    @State private var showPostOnboardingPaywall = false

    var body: some View {
        NavigationStack(path: $coordinator.path){
            ZStack {
                Image(.bgImg)
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
                        switch tabManager.selectedTab {
                        case .home:
                            HomeScreen(viewModel: homeViewModel)
                                .environmentObject(coordinator)
                                .tag(TabBarItem.home)
                        case .identify:
                            IdentifyScreen(selectedTab: $tabManager.selectedTab,currentMode: $currentMode)
                                .environmentObject(coordinator)
                                .tag(TabBarItem.identify)
                        case .history:
                            HistoryScreen()
                                .environmentObject(coordinator)
                                .tag(TabBarItem.history)
                        case .setting:
                            SettingView()
                                .environmentObject(coordinator)
                                .tag(TabBarItem.setting)
                        }
                    }
                }
                .id(tabManager.selectedTab)
                .navigationDestination(for: Route.self) { route in
                    coordinator.buildView(for: route)
                }
                .overlay (alignment: .bottom) {
                    if tabManager.selectedTab != .identify && !homeViewModel.showLoadingScreen{
                        VStack {
                            Spacer()
                            CustomTabBar(selectedTab: $tabManager.selectedTab)
                                .padding(.bottom, 24)
                        }
                    }
                }

            }
            .ignoresSafeArea(edges: .bottom)
        }
        .fullScreenCover(isPresented: $showPostOnboardingPaywall) {
            PaymentScreen()
        }
        .onAppear(perform: maybeShowPostOnboardingPaywall)
    }

    private func maybeShowPostOnboardingPaywall() {
        guard !hasSeenPostOnboardingPaywall,
              !SubscriptionManager.shared.isPremium else { return }
        hasSeenPostOnboardingPaywall = true
        // Small delay so it appears after the screen settles in.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showPostOnboardingPaywall = true
        }
    }
}

#Preview {
    MainScreen()
        .environmentObject(Coordinator())
        .environmentObject(TabManager())
}
