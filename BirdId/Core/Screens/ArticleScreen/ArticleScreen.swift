//
//  ArticleScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/30/1404 AP.
//

import SwiftUI

struct ArticleScreen: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var tabManager: TabManager
    @State private var showFullDescription: Bool = false
    
    var body: some View {
        ZStack{
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
            
            VStack{
                makeHeaderImageSection()
                    .padding(.bottom,24)
                    
                content()


//                Spacer()
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
            tabManager.selectedTab = .home
            }
        }
}

extension ArticleScreen {
    func makeHeaderImageSection() -> some View {
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
                    VStack (alignment: .leading,spacing: 8){
                        Text("Best secrets of attracting birds to your garen")
                            .font(.app(.Headline1))
                            .foregroundStyle(.text)
                        HStack(spacing: 4) {
                            Image(.clock)
                                .frame(width: 16,height: 16)
                            Text("6m")
                                .font(.app(.Micro1))
                                .foregroundStyle(.text)
                            Text("•")
                                .font(.app(.Micro1))
                                .foregroundStyle(.text)
                                .padding(.horizontal,4)
                            
                            Image(.document)
                                    .frame(width: 16,height: 16)
                                Text("Fall of 2025")
                                    .font(.app(.Micro1))
                                    .foregroundStyle(.text)
                            
                        }
                    }
                }
            }
            .padding(.horizontal,24)
            .padding(.bottom,24)

        }
        .frame(height: UIScreen.screenHeight / 2.42)
    }
    
    func content() -> some View {
        ScrollView(showsIndicators: false) {
            VStack{
                HStack{
                    Text("Habitat")
                        .font(.app(.Headline4))
                        .foregroundStyle(.text)
                    
                    
                    Spacer()
                }
                .padding(.horizontal,24)
                .padding(.bottom,24)
                
                VStack (alignment: .leading,spacing: 0){
                    Text("Macaws are native to the southern portion of North America (Mexico) plus Central America and South America. Evidence shows that the Caribbean also had native macawMacaws are native to the southern portion of North America (Mexico) plus Central America and South America. Evidence shows that the Caribbean also had native macawMacaws are native to the southern portion of North America (Mexico) plus Central America and South America. Evidence shows that the Caribbean also had native macawMacaws are native to the southern portion of North America (Mexico) plus Central America and South America. Evidence shows that the Caribbean also had native macawMacaws are native to the southern portion of North America (Mexico) plus Central America and South America. Evidence shows that the Caribbean also had native macaw")
                        .lineLimit(showFullDescription ? nil : 3)
                        .font(.app(.Sub1))
                        .foregroundStyle(.text)
                        .multilineTextAlignment(.leading)
                    
                    
                    Button (action: {
                        withAnimation(.easeInOut) {
                            showFullDescription.toggle()
                        }
                    }, label: {
                        Text(showFullDescription ? "Less" : "Read more")
                            .font(.app(.Headline4))
                            .foregroundStyle(Color(hex: "#BCBCBC"))
                    })
                }
                .padding(.horizontal,24)
                .padding(.bottom, UIScreen.screenHeight / 13.3)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    ArticleScreen()
        .environmentObject(Coordinator())
        .environmentObject(TabManager())
}
