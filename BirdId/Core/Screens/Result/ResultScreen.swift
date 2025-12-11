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
    let uploadResponse: UploadResponse
    var birdDetailResponse: BirdDetailResponse {
        uploadResponse.bird
    }
    @EnvironmentObject var tabManager: TabManager
    
    var body: some View {
        ZStack {
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                makeBirdImageSection()
                ScrollView {
                    BirdInfoItem(uploadResponse: uploadResponse)
                        .padding(.bottom, UIScreen.screenHeight / 13.3)
                        .padding(.bottom, 24)
                }
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
            tabManager.selectedTab = .history
        }
    }
}

extension ResultScreen {
    func makeBirdImageSection() -> some View {
        ZStack(alignment: .top) {
            // Get first photo from media
            if let firstPhoto = birdDetailResponse.media.first(where: { $0.type == "photo" }) {
                AsyncImage(url: URL(string: firstPhoto.storageKey)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay {
                                ProgressView()
                                    .tint(.white)
                            }
                    case .success(let image):
                        image
                            .resizable()
                    case .failure:
                        Image(.textResultBird)
                            .resizable()
                    @unknown default:
                        Image(.textResultBird)
                            .resizable()
                    }
                }
                .ignoresSafeArea()
            } else {
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
            }
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
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
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    BackButtonView()
                    Spacer()
                }
                Spacer()
                HStack {
                    let minLength = String(format: "%.1f", birdDetailResponse.size.lengthCm.min ?? 0)
                    let maxLength = String(format: "%.1f", birdDetailResponse.size.lengthCm.max ?? 0)
                    
                    VStack(alignment: .leading) {
                        Text(birdDetailResponse.scientificName)
                            .font(.app(.Headline1))
                            .foregroundStyle(.text)
                        Text("\(birdDetailResponse.taxonomy.genus ?? "") • \(minLength)-\(maxLength) cm • \(birdDetailResponse.lifeExpectancyYears ?? "") yrs")
                            .font(.app(.Micro1))
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
        .frame(height: UIScreen.screenHeight / 2.42)
        .padding(.bottom, 24)
    }
}

#Preview {
    ResultScreen(uploadResponse: .mock)
        .environmentObject(TabManager())
        .environmentObject(Coordinator())
}
