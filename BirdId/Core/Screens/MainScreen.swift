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
            ZStack {
                Image(.bgImg)
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeScreen()
                                .tag(TabBarItem.home)
                                .frame(maxHeight: UIScreen.screenHeight)
                        case .identify:
                            IdentifyScreen(selectedTab: $selectedTab)
                                .tag(TabBarItem.identify)
                                .frame(maxHeight: UIScreen.screenHeight)
                        case .history:
                            HistoryScreen()
                                .tag(TabBarItem.history)
                                .frame(maxHeight: UIScreen.screenHeight)
                        case .setting:
                            SettingView()
                                .tag(TabBarItem.setting)
                                .frame(maxHeight: UIScreen.screenHeight)
                        }
                    }
                }
                if selectedTab != .identify {
                    VStack {
                        Spacer()
                        CustomTabBar(selectedTab: $selectedTab)
                            .padding(.bottom, 24)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    MainScreen()
        .environmentObject(Coordinator())
}
