//
//  HistoryItem.swift
//  BirdId
//
//  Created by ali bakhsha on 8/20/1404 AP.
//

//
//  HistoryItem.swift
//  BirdId
//
//  Created by ali bakhsha on 8/20/1404 AP.
//

import SwiftUI

struct HistoryItem: View {
    @EnvironmentObject var coordinator: Coordinator
    
    let birds: [HistorySimpleModel]
    
    private let columns = [
        GridItem(. fixed(UIScreen.screenWidth / 2 - 32), spacing: 16),
        GridItem(.fixed(UIScreen.screenWidth / 2 - 32), spacing: 16)
    ]
    
    var body: some View {
        ScrollView(. vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(birds.enumerated()), id: \.offset) { index, bird in
                    Button {
                        coordinator.push(.birdDetail(birdId: bird.birdId))
                    } label: {
                        HistorySimpleCard(bird: bird)
                    }
                }
            }
            .padding(. horizontal, 24)
            .padding(.top, 8)
        }
    }
}

// MARK: - History Simple
struct HistorySimpleCard:  View {
    let bird:  HistorySimpleModel
    @State private var imageLoadFailed = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if imageLoadFailed {
                Image(.recordPoster)
                    .resizable()
//                    .aspectRatio(contentMode: .fill)
                    .scaledToFill()
                    .frame(height: UIScreen.screenHeight / 6.08)
                    . clipped()
                    .cornerRadius(28)
            } else {
                CachedAsyncImage(url: URL(string: bird.image)) { image in
                    image
                        .resizable()
//                        . aspectRatio(contentMode: .fill)
                        .scaledToFill()
                        .frame(width: UIScreen.screenWidth / 2 - 24,height: UIScreen.screenHeight / 6.08)
                        .clipped()
                        .cornerRadius(28)
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                            .tint(.white)
                    }
                    .frame(height: UIScreen.screenHeight / 6.08)
                    .cornerRadius(28)
                }
                .onAppear {
                    // Check if image exists in cache
                    if let url = URL(string: bird.image),
                       ImageCacheManager.shared.getImage(forKey: url.absoluteString) == nil {
                        // Image not in cache, will load
                    }
                }
            }
            
            LinearGradient(
                colors: [. clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(28)
            
            VStack(alignment: . leading, spacing: 4) {
                Text(bird.scientificName)
                    .font(.app(.Sub1))
                    .fontWeight(.semibold)
                    .foregroundStyle(. white)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .adaptiveGlassEffect(style: .clear)
            }
            .padding(.horizontal, 12)
            .padding(. vertical, 12)
        }
        .frame(maxWidth: . infinity)
        .frame(height: UIScreen.screenHeight / 6.08)
    }
}

#Preview {
    HistoryItem(birds: HistorySimpleModel.mockList)
        .environmentObject(Coordinator())
        .background(Color.black)
}
