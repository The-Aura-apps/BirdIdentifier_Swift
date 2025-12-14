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
            VStack(alignment: .leading) {
                Image(.birdHighlightsImg)
                    .resizable()
                    .frame(height: 160)
                
                Text("Best secrets of attracting birds to your garen")
                    .font(.app(.Sub1))
                    .foregroundStyle(.text)
                    .padding(.horizontal,24)
                    .padding(.vertical,16)
                    .multilineTextAlignment(.leading)
                
            }
        }
        .frame(width: UIScreen.screenWidth - 48,height: 240)
        .adaptiveGlassEffect(style: .clear)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    HighlightsCard()
        .environmentObject(Coordinator())
}
