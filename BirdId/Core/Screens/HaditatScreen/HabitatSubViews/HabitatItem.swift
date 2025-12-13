//
//  HabitatItem.swift
//  BirdId
//
//  Created by ali bakhsha on 9/20/1404 AP.
//

import SwiftUI

struct HabitatItem:  View {
    @EnvironmentObject var coordinator: Coordinator
    @ObservedObject var viewModel: HabitatViewModel
    
    private let columns = [
        GridItem(.fixed(UIScreen.screenWidth / 2 - 24), spacing: 16),
        GridItem(.fixed(UIScreen.screenWidth / 2 - 24), spacing: 16)
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        . foregroundColor(.red.opacity(0.7))
                    
                    Text("Error")
                        .font(.app(. Headline3))
                        . foregroundStyle(.text)
                    
                    Text(errorMessage)
                        .font(.app(.Sub2))
                        . foregroundStyle(.text.opacity(0.7))
                        . multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                . padding(.top, 50)
            } else if viewModel.filteredBirds.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bird")
                        .font(.system(size: 50))
                        .foregroundColor(.text.opacity(0.5))
                    
                    Text(viewModel.searchText.isEmpty ? "No birds found" :  "No results for '\(viewModel.searchText)'")
                        .font(.app(.Headline4))
                        .foregroundStyle(.text)
                }
                .padding(.top, 50)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredBirds) { bird in
                        Button {
                            // TODO: Navigate to bird detail
                            // coordinator.push(. BirdDetail(birdId:  bird.birdId))
                            print("🐦 Selected bird: \(bird.scientificName) - ID: \(bird.birdId)")
                        } label: {
                            HabitatCard(bird: bird)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
    }
}

struct HabitatCard: View {
    let bird: BirdHabitatSimple
    
    @State private var imageLoadFailed = false
    
    var body: some View {
        ZStack(alignment: . bottomLeading) {
            // Image Section
            if imageLoadFailed {
                placeholderImage
            } else {
                cachedImage
            }
            
            gradientOverlay
            birdNameLabel
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.screenHeight / 6.08)
    }
    
    // MARK: - Subviews
    private var placeholderImage: some View {
        Image(.recordPoster)
            .resizable()
            .frame(height: UIScreen.screenHeight / 6.08)
            .clipped()
            .cornerRadius(28)
    }
    
    private var cachedImage: some View {
        CachedAsyncImage(url:  URL(string: bird.image)) { image in
            image
                .resizable()
                .frame(height: UIScreen.screenHeight / 6.08)
                .clipped()
                .cornerRadius(28)
        } placeholder: {
            ZStack {
                Color.gray.opacity(0.3)
                ProgressView()
                    .tint(. white)
            }
            . frame(height: UIScreen.screenHeight / 6.08)
            .cornerRadius(28)
        }
        .onAppear {
            // Check if image exists in cache
            if let url = URL(string: bird.image),
               ImageCacheManager.shared.getImage(forKey: url.absoluteString) == nil {
                // Image not in cache, will load
            }
        }
        .onDisappear {
            // Optional: Handle cleanup if needed
        }
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            colors:  [. clear, .black.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
        .cornerRadius(28)
    }
    
    private var birdNameLabel: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(bird.scientificName)
                .font(. app(.Sub1))
                .fontWeight(.semibold)
                .foregroundStyle(. white)
                .lineLimit(2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .adaptiveGlassEffect(style: .clear)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    HabitatItem(viewModel:  HabitatViewModel())
        .environmentObject(Coordinator())
        .background(Color.black)
}
