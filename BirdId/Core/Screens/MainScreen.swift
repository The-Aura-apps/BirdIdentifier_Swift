//
//  MainScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 7/18/1404 AP.
//

import SwiftUI

struct MainScreen: View {
    @State private var selectedTab: TabBarItem = .home
    @EnvironmentObject var coordinator : Coordinator
    var body: some View {
        NavigationStack(path: $coordinator.path){
            ZStack {
                Image(.bgImg)
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
                        switch selectedTab {
                        case .home:
                            HomeScreen()
                                .tag(TabBarItem.home)
                        case .identify:
                            IdentifyScreen(selectedTab: $selectedTab)
                                .tag(TabBarItem.identify)
                        case .history:
                            HistoryScreen()
                                .tag(TabBarItem.history)
                        case .setting:
                            SettingView()
                                .tag(TabBarItem.setting)
                        }


                    }
                }
                .navigationDestination(for: Route.self) { route in
                    coordinator.buildView(for: route)
                }
                .overlay (alignment: .bottom) {
                    if selectedTab != .identify {
                        VStack {
                            Spacer()
                            CustomTabBar(selectedTab: $selectedTab)
                                .padding(.bottom, 24)
                        }
                    }
                }

            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    MainScreen()
        .environmentObject(Coordinator())
}
