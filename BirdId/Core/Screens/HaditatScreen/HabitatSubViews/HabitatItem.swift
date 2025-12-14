//
//  HabitatItem. swift
//  BirdId
//
//  Created by ali bakhsha on 9/20/1404 AP.
//

import SwiftUI

struct HabitatItem: View {
    @EnvironmentObject var coordinator:  Coordinator
    @ObservedObject var viewModel: HabitatViewModel
    
    private let columns = [
        GridItem(. fixed(UIScreen.screenWidth / 2 - 24), spacing: 16),
        GridItem(.fixed(UIScreen.screenWidth / 2 - 24), spacing: 16)
    ]
    
    var body: some View {
        ScrollView(. vertical, showsIndicators: false) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(. top, 50)
                    .tint(.white)
            } else if viewModel.isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    . padding(.top, 50)
                    .tint(. white)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing:  16) {
                    Image(systemName: "exclamationmark.triangle")
                        . font(.system(size: 50))
                        .foregroundColor(.red.opacity(0.7))
                    
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
            } else if viewModel.searchText.isEmpty {
                if viewModel.birds.isEmpty {
                    emptyStateView
                } else {
                    simpleBirdsGrid
                }
            } else {
                if viewModel.filteredBirdsDetail.isEmpty {
                    emptySearchStateView
                } else {
                    detailedBirdsGrid
                }
            }
        }
    }
    
    // MARK: - Simple Birds Grid
    private var simpleBirdsGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.birds) { bird in
                Button {
                    print("🐦 Selected bird: \(bird.scientificName) - ID: \(bird.birdId)")
                    viewModel.clearSearch()
                    coordinator.push(. birdDetail(birdId:  bird.birdId))
                } label: {
                    HabitatSimpleCard(bird: bird)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Detailed Birds Grid
    private var detailedBirdsGrid: some View {
        LazyVGrid(columns:  columns, spacing: 16) {
            ForEach(viewModel.filteredBirdsDetail, id: \.id) { bird in
                Button {
                    print("🐦 Selected bird: \(bird.scientificName) - ID: \(bird.id)")
                    viewModel.clearSearch()
                    coordinator.push(.birdDetail(birdId: bird.id))
                } label: {
                    HabitatDetailCard(bird: bird)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Empty States
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bird")
                .font(.system(size: 50))
                .foregroundColor(.text.opacity(0.5))
            
            Text("No birds found")
                .font(.app(.Headline4))
                .foregroundStyle(. text)
        }
        . padding(. top, 50)
    }
    
    private var emptySearchStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.text.opacity(0.5))
            
            Text("No results for '\(viewModel.searchText)'")
                .font(.app(.Headline4))
                .foregroundStyle(.text)
        }
        .padding(.top, 50)
    }
}

// MARK:  - Simple Card
struct HabitatSimpleCard: View {
    let bird:  BirdHabitatSimple
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageUrl = bird.image, !imageUrl.isEmpty {
                CachedAsyncImage(url:  URL(string: imageUrl)) { image in
                    image
                        . resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.screenWidth / 2 - 24, height: UIScreen.screenHeight / 6.08)
                        .clipped()
                        .cornerRadius(28)
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                            .tint(.white)
                    }
                    . frame(height: UIScreen.screenHeight / 6.08)
                    .cornerRadius(28)
                }
            } else {
                placeholderImage
            }
            
            gradientOverlay
            birdNameLabel(bird.scientificName)
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.screenHeight / 6.08)
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "bird.fill")
                .font(.system(size: 50))
                .foregroundColor(. white.opacity(0.6))
        }
        .frame(width: UIScreen.screenWidth / 2 - 24, height:  UIScreen.screenHeight / 6.08)
        .cornerRadius(28)
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
        .cornerRadius(28)
    }
    
    private func birdNameLabel(_ name: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(. app(.Sub1))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .adaptiveGlassEffect(style:  .clear)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Detail Card
struct HabitatDetailCard:  View {
    let bird: BirdDetailResponse
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let firstMedia = bird.media.first(where: { $0.type == "photo" }) {
                CachedAsyncImage(url: URL(string: firstMedia.storageKey)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.screenWidth / 2 - 24, height: UIScreen.screenHeight / 6.08)
                        . clipped()
                        .cornerRadius(28)
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                            . tint(.white)
                    }
                    .frame(height: UIScreen.screenHeight / 6.08)
                    . cornerRadius(28)
                }
            } else {
                placeholderImage
            }
            
            gradientOverlay
            birdNameLabel(bird.scientificName)
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.screenHeight / 6.08)
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "bird.fill")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(width: UIScreen.screenWidth / 2 - 24, height: UIScreen.screenHeight / 6.08)
        .cornerRadius(28)
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.8)],
            startPoint: . top,
            endPoint: . bottom
        )
        .cornerRadius(28)
    }
    
    private func birdNameLabel(_ name: String) -> some View {
        VStack(alignment:  .leading, spacing: 4) {
            Text(name)
                .font(.app(.Sub1))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
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
    HabitatItem(viewModel: HabitatViewModel())
        .environmentObject(Coordinator())
        .background(Color.black)
}
