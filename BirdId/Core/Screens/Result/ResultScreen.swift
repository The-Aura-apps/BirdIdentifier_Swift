//
//  ResultScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/8/1404 AP.
//

import SwiftUI

struct ResultScreen: View {
    
    
//    @Binding var selectedTab: TabBarItem
    @EnvironmentObject var tabManager: TabManager
    
    var body: some View {
            ZStack {
                Image(.bgImg)
                    .resizable()
                    .ignoresSafeArea()
                
                    VStack {
                        makeBirdImageSection()
                        ScrollView {
                            BirdInfoItem()
                        }
                        .padding(.bottom, UIScreen.screenHeight / 13.3)
                        .padding(.bottom, 24)
                }
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
                tabManager.selectedTab = .history
            }
        }
}

extension ResultScreen{
    
    func makeBirdImageSection() -> some View {
        ZStack (alignment: .top) {
            Image(.textResultBird)
                .resizable()
                .mask(
                    VStack(spacing: 0) {
                        Color.white
                        RoundedRectangle(cornerRadius: 24)
                            .frame(height: 24)
                    }
                    )
                .ignoresSafeArea()

            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .mask(
                VStack(spacing: 0) {
                    Color.white
                    RoundedRectangle(cornerRadius: 24)
                        .frame(height: 24)
                }
                )
            .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .mask(
                VStack(spacing: 0) {
                    Color.white
                    RoundedRectangle(cornerRadius: 24)
                        .frame(height: 24)
                }
                )
            .ignoresSafeArea()
            
            VStack {
                HStack{
                    BackButtonView()
                    Spacer()
                }
                Spacer()
                HStack {
                    VStack (alignment: .leading){
                        Text("Bird Name")
                            .font(.app(.Headline1))
                            .foregroundStyle(.text)
                        Text("Parrot • Large • 30+ yea")
                            .font(.app(.Micro1))
                            .foregroundStyle(.text)
                    }
                    Spacer()
                    HStack{
                        Image(.play)
                            .padding(.trailing,4)
                        Text("Play bird song")
                            .font(.app(.Sub2))
                            .foregroundStyle(.text)
                    }
                    .padding(.horizontal,12)
                    .padding(.vertical,10)
                    .adaptiveGlassEffect(style: .clear)
                }
            }
            .padding(.horizontal,24)
            .padding(.bottom,24)

        }
        .frame(height: UIScreen.screenHeight / 2.42)
        .padding(.bottom,24)
    }
    
}

#Preview {
    ResultScreen()
}
