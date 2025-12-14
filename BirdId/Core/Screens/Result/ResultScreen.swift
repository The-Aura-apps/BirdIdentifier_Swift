//
//  ResultScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/8/1404 AP.
//
//
//  ResultScreen.swift
//  BirdId
//
//  Refactored: Use BirdDetailResponse directly
//


import SwiftUI

struct ResultScreen: View {
    // Two possible init methods
    let uploadResponse:  UploadResponse?
    let birdId: Int?
    
    @StateObject private var viewModel = BirdDetailViewModel()
    @EnvironmentObject var tabManager: TabManager
    
    var birdDetailResponse: BirdDetailResponse?  {
        if let uploadResponse = uploadResponse {
            return uploadResponse.bird
        }
        return viewModel.birdDetail
    }
    
    // Init from UploadResponse (existing flow)
    init(uploadResponse:  UploadResponse) {
        self.uploadResponse = uploadResponse
        self.birdId = nil
    }
    
    // Init from bird ID (history flow)
    init(birdId: Int) {
        self.uploadResponse = nil
        self.birdId = birdId
    }
    
    var body:  some View {
        ZStack {
            Image(. bgImg)
                .resizable()
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    . scaleEffect(1.5)
                    .tint(.text)
            } else if let bird = birdDetailResponse {
                    VStack(spacing: 0) {
                        makeBirdImageSection(bird: bird)
                            .padding(.bottom,24)
                        ScrollView {
                            BirdInfoItem(birdDetail:  bird)
                                .padding(. bottom, UIScreen.screenHeight / 13.3)
                                .padding(.bottom, 24)
                        }
                    }
                .ignoresSafeArea(edges: .top)
            } else {
                Text("No data available")
                    .foregroundStyle(.text)
            }
        }
        .overlay(alignment: .bottom) {
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $tabManager.selectedTab)
                    . padding(.bottom, 24)
            }
        }
        . ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let birdId = birdId, viewModel.birdDetail == nil {
                viewModel.fetchBirdDetail(id: birdId)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            if let birdId = birdId {
                Button("Retry") {
                    viewModel.retry(id: birdId)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}

extension ResultScreen {
    func makeBirdImageSection(bird:  BirdDetailResponse) -> some View {
        ZStack(alignment:  .top) {
            // Get first photo from media
            if let firstPhoto = bird.media.first(where: { $0.type == "photo" }) {
                CachedAsyncImage(url: URL(string: firstPhoto.storageKey)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.screenWidth)
                        .frame(minHeight: UIScreen.screenHeight * 0.4, maxHeight: UIScreen.screenHeight * 0.6)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: UIScreen.screenWidth)
                        .frame(height: UIScreen.screenHeight * 0.5)
                        .overlay {
                            ProgressView()
                                .tint(.white)
                        }
                }
            } else {
                Image(.textResultBird)
                    . resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.screenWidth)
                    .frame(minHeight: UIScreen.screenHeight * 0.4, maxHeight: UIScreen.screenHeight * 0.6)
                    .clipped()
            }
            
            // Gradient overlays
            LinearGradient(
                gradient:  Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.3),
                    Color.clear
                ]),
                startPoint: .top,
                endPoint: .center
            )
            
            // Content overlay
            VStack {
                HStack {
                    BackButtonView()
                    Spacer()
                }
                . padding(.top, 48)
                
                Spacer()
                
                HStack(alignment: .bottom) {
                    let minLength = String(format: "%.1f", bird.size.lengthCm.min ??  0)
                    let maxLength = String(format: "%. 1f", bird.size.lengthCm.max ?? 0)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bird.scientificName)
                            .font(.app(. Headline1))
                            . foregroundStyle(.text)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        
                        Text("\(bird.taxonomy.genus ?? "") • \(minLength)-\(maxLength) cm • \(bird.lifeExpectancyYears ?? "") yrs")
                            .font(. app(.Micro1))
                            .foregroundStyle(.text)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    
                    Spacer()
                    
//                    HStack {
//                        Image(.play)
//                            .padding(.trailing, 4)
//                        Text("Play bird song")
//                            .font(.app(.Sub2))
//                            .foregroundStyle(. text)
//                    }
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 10)
//                    . adaptiveGlassEffect(style: .clear)
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .frame(minHeight: UIScreen.screenHeight * 0.4, maxHeight: UIScreen.screenHeight * 0.6)
    }
}

#Preview {
    ResultScreen(uploadResponse: . mock)
        .environmentObject(TabManager())
        .environmentObject(Coordinator())
}
