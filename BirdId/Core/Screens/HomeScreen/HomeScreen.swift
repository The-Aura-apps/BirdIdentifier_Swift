//
//  HomeScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 7/20/1404 AP.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var viewModel = HomeScreenViewModel()
    var body: some View {
        ZStack{
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack {
                    //MARK: TextField
                    SearchTextField(searchText: $viewModel.searchText)
                        .padding(.bottom,16)
                        .padding(.horizontal,24)
                        .padding(.top,24)
                    HStack(spacing: 24) {
                        Button {
                            //TODO: Get Photo Logic
                            coordinator.identifyMode = .camera
                            coordinator.push(.IdentifyScreen(currentMode: .camera))
                            
                            
                        } label: {
                            HStack {
                                Image(.camera)
                                    .padding(.trailing,8)
                                Text("Photo\nIdentification")
                                    .font(.app(.Sub2))
                                    .foregroundStyle(.text)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical,14)
                            .padding(.horizontal,16)
                            .adaptiveGlassEffect(style: .clear)
                        }
                        Button {
                            //TODO: Get Sound Logic
                            coordinator.identifyMode = .mic
                            coordinator.push(.IdentifyScreen(currentMode: .mic))
                            
                        } label: {
                            HStack {
                                Image(.microphone)
                                    .padding(.trailing,8)
                                Text("Sound\nIdentification")
                                    .font(.app(.Sub2))
                                    .foregroundStyle(.text)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical,14)
                            .padding(.horizontal,16)
                            .adaptiveGlassEffect(style: .clear)
                        }
                        
                    }
                    .frame(width: UIScreen.screenWidth - 48)
                    .padding(.bottom,24)
                    
                    VStack(alignment: .leading,spacing: 16) {
                        HStack {
                            Text("Based on bird’s habitat")
                                .font(.app(.Headline4))
                                .foregroundStyle(.text)
                                .padding(.leading,24)
                            Spacer()
                        }
                        //MARK: Bird`s Habitat Section
                        BirdHabitatItem(viewModel: viewModel)
                    }
                    .padding(.bottom,24)
                    
                    VStack(alignment: .center,spacing: 16) {
                        HStack {
                            Text("Highlights")
                                .font(.app(.Headline4))
                                .foregroundStyle(.text)
                                .padding(.leading,24)
                            
                            Spacer()
                        }
                        
                        //MARK: Highlights Section
                        ForEach(0..<3) { _ in
                            HighlightsCard()
                                .padding(.bottom,16)
                        }
                    }
                    .padding(.bottom, UIScreen.screenHeight / 13.3)
                    .padding(.bottom, 24)
                }
            }

        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomeScreen()
        .environmentObject(Coordinator())
}
