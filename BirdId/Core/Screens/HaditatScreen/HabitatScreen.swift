//
//  HabitatScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/30/1404 AP.
//

import SwiftUI

struct HabitatScreen: View {
    let title: String
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var tabManager: TabManager
    @StateObject var viewModel = HabitatViewModel()
    
    var body: some View {
        ZStack{
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
            
            VStack{
                HStack{
                    BackButtonView()
                    Spacer()
                    Text(title)
                        .font(.app(.Headline1))
                        .foregroundStyle(.text)
                    Spacer()
                    Image(systemName: "xmark")
                        .frame(width: 48, height: 48)
                        .opacity(0)
                }
                .padding(.bottom,24)
                SearchTextField(searchText: $viewModel.searchText)
                    .padding(.bottom,24)
                ScrollView(showsIndicators: false) {
                    HistoryItem()
                        .padding(.bottom, UIScreen.screenHeight / 13.3)
                        .padding(.bottom, 32)
                }
                Spacer()
            }
            .padding(.horizontal,24)
        }
        .overlay (alignment: .bottom) {
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
            }
        }
}

#Preview {
    HabitatScreen(title: "Habitat")
        .environmentObject(TabManager())
        .environmentObject(Coordinator())
}
