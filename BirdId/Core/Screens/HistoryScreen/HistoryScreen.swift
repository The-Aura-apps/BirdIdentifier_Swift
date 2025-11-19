//
//  HistoryScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/20/1404 AP.
//

import SwiftUI

struct HistoryScreen: View {
    var body: some View {
        ZStack{
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
                VStack{
                    HStack {
                        Text("Records")
                            .font(.app(.Headline1))
                            .foregroundStyle(.text)
                        Spacer()
                    }
                    .padding(.top,24)
                    ScrollView {
                        HistoryItem()
                            .padding(.bottom, UIScreen.screenHeight / 13.3)
                            .padding(.bottom, 32)
                    }
                }
                .padding(.horizontal,24)
            }
        
    }
}

#Preview {
    HistoryScreen()
}
