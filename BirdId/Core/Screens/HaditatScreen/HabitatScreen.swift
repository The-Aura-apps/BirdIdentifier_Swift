//
//  HabitatScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/30/1404 AP.
//


import SwiftUI

struct HabitatScreen: View {
    let habitatId: Int
    let title: String
    let description: String
    
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var tabManager: TabManager
    @StateObject var viewModel = HabitatViewModel()
    
    var body: some View {
        ZStack {
            Image(. bgImg)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    BackButtonView()
                        .padding(.trailing, 24)
                    SearchTextField(searchText: $viewModel.searchText)
                }
                . padding(.bottom, 16)
                .padding(.horizontal, 24)
                
                Text(title)
                    .font(.app(.Headline1))
                    .foregroundStyle(.text)
                
                Text(description)
                    .font(.app(.Sub2))
                    .foregroundStyle(.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    . padding(.top, 8)
                    .padding(.bottom, 16)
                
                HabitatItem(viewModel:  viewModel)
                    .padding(.bottom, UIScreen.screenHeight / 13.3)
                    .padding(.bottom, 32)
                
                Spacer()
            }
        }
        .overlay(alignment: .bottom) {
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $tabManager.selectedTab)
                    .padding(.bottom, 24)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            tabManager.selectedTab = .home
            viewModel.loadHabitatBirds(id: habitatId)
        }
    }
}

#Preview {
    HabitatScreen(
        habitatId: 2,
        title: "Forest",
        description: "Forest habitats are densely wooded areas"
    )
    .environmentObject(TabManager())
    .environmentObject(Coordinator())
}
