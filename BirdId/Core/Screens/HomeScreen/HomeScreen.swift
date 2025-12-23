//
//  HomeScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 7/20/1404 AP.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var coordinator:  Coordinator
    @ObservedObject var viewModel: HomeScreenViewModel
    
    init(viewModel: HomeScreenViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack {
                    //MARK: TextField
                    SearchTextField(searchText:  $viewModel.searchText)
                        .padding(.bottom, 16)
                        .padding(.horizontal, 24)
                        . padding(.top, 24)
                    
                    HStack(spacing: 24) {
                        Button {
                            coordinator.identifyMode = .camera
                            coordinator.push(.IdentifyScreen(currentMode: .camera))
                        } label: {
                            HStack {
                                Image(. camera)
                                    .padding(. trailing, 8)
                                Text("Photo\nIdentification")
                                    .font(.app(.Sub2))
                                    .foregroundStyle(.text)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.75)
                                    .dynamicTypeSize(.small ... .xxLarge)
                                    .multilineTextAlignment(.leading)
                            }
                            . padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .adaptiveGlassEffect(style: .clear)
                        }
                        Button {
                            coordinator.identifyMode = .mic
                            coordinator.push(. IdentifyScreen(currentMode: . mic))
                        } label:  {
                            HStack {
                                Image(.microphone)
                                    .padding(.trailing, 8)
                                Text("Sound\nIdentification")
                                    .font(.app(.Sub2))
                                    .foregroundStyle(.text)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.75)
                                    .dynamicTypeSize(.small ... .xxLarge)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .adaptiveGlassEffect(style:  .clear)
                        }
                    }
                    .frame(width: UIScreen.screenWidth - 48)
                    . padding(.bottom, 24)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Based on bird's habitat")
                                .font(.app(. Headline4))
                                .foregroundStyle(.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .dynamicTypeSize(.small ... .xxLarge)
                                .padding(.leading, 24)
                            Spacer()
                        }
                        //MARK: Bird`s Habitat Section
                        BirdHabitatItem(viewModel: viewModel)
                    }
                    .padding(.bottom, 24)
                    
                    VStack(alignment: . center, spacing: 16) {
                        HStack {
                            Text("Highlights")
                                .font(.app(.Headline4))
                                .foregroundStyle(.text)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .dynamicTypeSize(.small ... .xxLarge)
                                . padding(.leading, 24)
                            
                            Spacer()
                        }
                        
                        //MARK:  Highlights Section
                        ForEach(0..<3) { _ in
                            HighlightsCard()
                                .padding(.bottom, 16)
                        }
                    }
                    .padding(.bottom, UIScreen.screenHeight / 13.3)
                    . padding(.bottom, 24)
                }
            }
            .blur(radius: viewModel.showSearchResults ? 8 : 0)
            .animation(.easeInOut(duration: 0.3), value: viewModel.showSearchResults)
            
            // MARK: Search Results Overlay
            if viewModel.showSearchResults {
                SearchResultsOverlay(viewModel: viewModel)
                    .environmentObject(coordinator)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.showSearchResults)
            }
            
            // MARK: Loading Screen
            if viewModel.showLoadingScreen {
                SearchResultScreen()
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.setCoordinator(coordinator)
        }
    }
}

// MARK: - Search Results Overlay
struct SearchResultsOverlay: View {
    @ObservedObject var viewModel: HomeScreenViewModel
    @EnvironmentObject var coordinator:  Coordinator
    
    var body:  some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.clearSearch()
                    }
                }
            
            VStack(spacing: 0) {
                HStack {
                    SearchTextField(searchText: $viewModel.searchText)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                }
                VStack(spacing: 0) {
                    if viewModel.isSearching {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding()
                            Spacer()
                        }
                        .frame(height: 100)
                    } else if viewModel.searchResults.isEmpty && viewModel.searchText.count >= 3 {
                        HStack {
                            Spacer()
                            Text("No results found")
                                .font(. app(.Sub1))
                                .foregroundStyle(.text.opacity(0.6))
                                .padding()
                            Spacer()
                        }
                        .frame(height: 100)
                    } else if !viewModel.searchResults.isEmpty {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.searchResults) { bird in
                                    BirdSearchResultRow(bird: bird)
                                        .onTapGesture {
                                            handleBirdSelection(bird:  bird)
                                        }
                                    
                                    if bird.id != viewModel.searchResults.last?.id {
                                        Divider()
                                            . background(Color.white.opacity(0.3))
                                            .padding(. horizontal, 16)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .frame(maxHeight: UIScreen.screenHeight - 200)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .adaptiveGlassEffect(style:  .clear)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y:  5)
                )
                .padding(.horizontal, 24)
                .padding(.top, 4)
                
                Spacer()
            }
            .padding(.bottom, UIScreen.screenHeight / 13.3)
            .padding(.bottom, 24)
        }
    }
    
    private func handleBirdSelection(bird: BirdSearchItem) {
        viewModel.fetchBirdDetail(scientificName: bird.scientificName)
    }
}

// MARK: - Bird Search Result Row
struct BirdSearchResultRow: View {
    let bird: BirdSearchItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(bird.scientificName)
                .font(. app(.Sub1))
                .foregroundStyle(.text)
                .minimumScaleFactor(0.75)
                .dynamicTypeSize(.small ... .xxLarge)
                .italic()
            
            Text(bird.englishName)
                .font(.app(.Sub2))
                .foregroundStyle(.text.opacity(0.8))
                .minimumScaleFactor(0.75)
                .dynamicTypeSize(.small ... .xxLarge)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.clear)
        .contentShape(Rectangle())
    }
}

#Preview {
    HomeScreen(viewModel: HomeScreenViewModel())
        .environmentObject(Coordinator())
}
