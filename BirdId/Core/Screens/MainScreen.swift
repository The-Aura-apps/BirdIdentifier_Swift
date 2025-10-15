//
//  MainScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 7/18/1404 AP.
//

import SwiftUI

struct MainScreen: View {
    @State private var selectedTab: TabBarItem = .home

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
                        Text("Identify Screen")
                            .tag(TabBarItem.identify)
                            .frame(maxHeight: UIScreen.screenHeight)
                    case .history:
                        Text("History Screen")
                            .tag(TabBarItem.history)
                            .frame(maxHeight: UIScreen.screenHeight)
                    }
                }
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    MainScreen()
}
