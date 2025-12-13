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
    let uploadResponse: UploadResponse?
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
                VStack {
                    makeBirdImageSection(bird: bird)
                    ScrollView {
                        BirdInfoItem(birdDetail: bird)
                            .padding(.bottom, UIScreen.screenHeight / 13.3)
                            .padding(.bottom, 24)
                    }
                }
            } else {
                Text("No data available")
                    .foregroundStyle(.text)
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
        ZStack(alignment: .top) {
            // Get first photo from media
            if let firstPhoto = bird.media.first(where: { $0.type == "photo" }) {
                CachedAsyncImage(url: URL(string: firstPhoto.storageKey)) { image in
                    image
                        .resizable()
//                        .aspectRatio(contentMode: . fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            ProgressView()
                                .tint(.white)
                        }
                }
                .ignoresSafeArea()
            } else {
                Image(.textResultBird)
                    . resizable()
                    .mask(
                        VStack(spacing: 0) {
                            Color.white
                            RoundedRectangle(cornerRadius: 24)
                                .frame(height: 24)
                        }
                    )
                    .ignoresSafeArea()
            }
            
            LinearGradient(
                gradient:  Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            LinearGradient(
                gradient:  Gradient(colors: [
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    BackButtonView()
                    Spacer()
                }
                Spacer()
                HStack {
                    let minLength = String(format: "%.1f", bird.size.lengthCm.min ??  0)
                    let maxLength = String(format: "%. 1f", bird.size.lengthCm.max ?? 0)
                    
                    VStack(alignment: .leading) {
                        Text(bird.scientificName)
                            .font(.app(. Headline1))
                            .foregroundStyle(.text)
                        Text("\(bird.taxonomy.genus ??  "") • \(minLength)-\(maxLength) cm • \(bird.lifeExpectancyYears ?? "") yrs")
                            .font(. app(. Micro1))
                            .foregroundStyle(.text)
                    }
                    Spacer()
                    HStack {
                        Image(.play)
                            .padding(.trailing, 4)
                        Text("Play bird song")
                            .font(.app(.Sub2))
                            .foregroundStyle(.text)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .adaptiveGlassEffect(style: .clear)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(height: UIScreen.screenHeight / 2.80)
        .padding(.bottom, 24)
    }
}

#Preview {
    ResultScreen(uploadResponse: .mock)
        .environmentObject(TabManager())
        .environmentObject(Coordinator())
}
