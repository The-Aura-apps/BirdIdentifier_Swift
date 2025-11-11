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
            ScrollView{
                VStack{
                    HStack {
                        Text("Records")
                            .font(.app(.Headline1))
                            .foregroundStyle(.text)
                        Spacer()
                    }
                    .padding(.vertical,24)
                    Spacer()
                    HistoryItem()
                }
                .padding(.horizontal,24)
            }
        }
        
    }
}

#Preview {
    HistoryScreen()
}
