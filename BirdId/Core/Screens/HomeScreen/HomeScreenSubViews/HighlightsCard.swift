//
//  HighlightsCard.swift
//  BirdId
//
//  Created by ali bakhsha on 7/23/1404 AP.
//

import SwiftUI

struct HighlightsCard: View {
    
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        //TODO: Add Button
        Button {
            //TODO: add article TITLE!!
            coordinator.push(.ArticleScreen(title: ""))
        } label: {
            VStack(alignment: .leading , spacing: 0) {
                Image(.birdHighlightsImg)
                    .resizable()
                    .scaledToFill()
                    .frame(height: UIScreen.screenHeight / 5.325)
                    .clipped()
                
                Text("Best secrets of attracting birds to your garen")
                    .font(.app(.Sub1))
                    .foregroundStyle(.text)
                    .padding(.horizontal,24)
                    .padding(.vertical,16)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .dynamicTypeSize(.small ... .xxLarge)
                    .multilineTextAlignment(.leading)
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .buttonStyle(.plain)
        .frame(width: UIScreen.screenWidth - 48,height: UIScreen.screenHeight / 3.55)
        .adaptiveGlassEffect(style: .clear)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    HighlightsCard()
        .environmentObject(Coordinator())
}
