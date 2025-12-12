//
//  HabitatItem.swift
//  BirdId
//
//  Created by ali bakhsha on 9/20/1404 AP.
//

import SwiftUI

struct HabitatItem: View {
    @EnvironmentObject var coordinator: Coordinator
    
    private let columns = [
        GridItem(.fixed(UIScreen.screenWidth / 2 - 24), spacing: 16),
        GridItem(.fixed(UIScreen.screenWidth / 2 - 24), spacing: 16)
    ]
    
    private let mockBirds: [UploadResponse] = [
        .mock,
        .mock, .mock, .mock, .mock,
        .mock, .mock, .mock, .mock,
        .mock, .mock
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(mockBirds, id: \.observation.id) { bird in
                    Button {
                        coordinator.push(.ResultScreen(uploadResponse:  bird))
                    } label: {
                        HabitatCard(bird: bird.bird)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
}

struct HabitatCard: View {
    let bird: BirdDetailResponse
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(.recordPoster)
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.screenHeight / 6.08)
                .clipped()
                .cornerRadius(28)
            
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(28)
            
            VStack(alignment: .leading, spacing: 4) {
                if let englishName = bird.commonNames.first(where: { $0.language == "en" })?.name {
                    Text(englishName)
                        .font(.app(.Sub1))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                } else {
                    Text("Unknown Bird")
                        .font(.app(.Sub1))
                        .foregroundStyle(.white)
                }
                
                Text(bird.scientificName)
                    .font(.app(.Micro1))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.screenHeight / 6.08)
    }
}

#Preview {
    HabitatItem()
        .environmentObject(Coordinator())
        .background(Color.black)
}
