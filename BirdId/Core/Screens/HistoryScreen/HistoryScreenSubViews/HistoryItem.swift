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
        GridItem(.fixed(UIScreen.screenWidth / 2 - 24), spacing: 16),
        GridItem(.fixed(UIScreen.screenWidth / 2 - 24), spacing: 16)
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(birds) { bird in
                    Button {
                        // TODO: اینجا باید navigation به صفحه جزئیات اضافه بشه
                        // coordinator.push(.BirdDetail(bird: bird))
                    } label: {
                        HistorySimpleCard(bird: bird)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
}

// MARK: - کارت ساده برای History Simple
struct HistorySimpleCard: View {
    let bird: HistorySimpleModel
    @State private var imageLoadFailed = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if imageLoadFailed {
                Image(.recordPoster)
                    .resizable()
                    .scaledToFill()
                    .frame(height: UIScreen.screenHeight / 6.08)
                    .clipped()
                    .cornerRadius(28)
            } else {
                AsyncImage(url: URL(string: bird.image)) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color.gray.opacity(0.3)
                            ProgressView()
                                .tint(.white)
                        }
                    case .success(let image):
                        image
                            .resizable()
//                            .scaledToFill()
                    case .failure:
                        Image(.recordPoster)
                            .resizable()
                            .scaledToFill()
                            .onAppear {
                                imageLoadFailed = true
                            }
                    @unknown default:
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(height: UIScreen.screenHeight / 6.08)
                .clipped()
                .cornerRadius(28)
            }
            
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bird.scientificName)
                    .font(.app(.Sub1))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
//                    .lineLimit(1)
                    .padding(.horizontal,8)
                    .padding(.vertical,4)
                    .adaptiveGlassEffect(style: .clear)
                
//                Text(bird.scientificName)
//                    .font(.app(.Micro1))
//                    .foregroundStyle(.white.opacity(0.85))
//                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.screenHeight / 6.08)
    }
}

#Preview {
    HistoryItem(birds: HistorySimpleModel.mockList)
        .environmentObject(Coordinator())
        .background(Color.black)
}
