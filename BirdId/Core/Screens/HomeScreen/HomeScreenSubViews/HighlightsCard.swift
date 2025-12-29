//
//  HighlightsCard.swift
//  BirdId
//
//  Created by ali bakhsha on 7/23/1404 AP.
//

import SwiftUI

struct HighlightsCard: View {
    
    @EnvironmentObject var coordinator: Coordinator
    let article: Article
    
    var body: some View {
        Button {
            coordinator.push(.ArticleScreen(title: article.id))
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Image Container with CachedAsyncImage
                CachedAsyncImage(
                    url: URL(string: article.photoUrl),
                    content: { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: UIScreen.screenHeight / 5.325)
                            .clipped()
                    },
                    placeholder: {
                        ZStack {
                            Color.gray.opacity(0.2)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        .frame(height: UIScreen.screenHeight / 5.325)
                    }
                )
                
                // Title
                Text(article.title)
                    .font(.app(.Sub1))
                    .foregroundStyle(.text)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .dynamicTypeSize(.small ... .xxLarge)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .buttonStyle(.plain)
        .frame(width: UIScreen.screenWidth - 48, height: UIScreen.screenHeight / 3.55)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .adaptiveGlassEffect(style: .clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .contentShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    HighlightsCard(article: Article(
        id: "1",
        title: "Best secrets of attracting birds to your garden",
        content: "Sample content...",
        photoUrl: "https://example.com/image.jpg",
        createdAt: "2025-12-24T06:04:42.676Z",
        updatedAt: "2025-12-24T06:04:42.676Z"
    ))
    .environmentObject(Coordinator())
}
