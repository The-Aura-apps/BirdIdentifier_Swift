//
//  SearchResultScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/8/1404 AP.
//

import SwiftUI
import Combine

struct SearchResultScreen: View {
    @State private var dots = ""
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack{
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
            VStack{
                HStack{
                    BackButtonView()
                    Spacer()
                }
                Spacer()
                LottieView(animationName: "SearchingBirdAnimation")
                    .frame(height: UIScreen.screenHeight / 2.84)
                Spacer()
                HStack(spacing: 0){
                    Text("Analyzing feathers")
                        .font(.app(.Sub1))
                        .foregroundStyle(.text)
                    Text(dots)
                        .font(.app(.Sub1))
                        .foregroundStyle(.text)
                        .frame(width: 24, alignment: .leading)
                }
                .padding(.bottom,32)
                .onReceive(timer) { _ in
                    if dots.count >= 3 {
                        dots = ""
                    } else {
                        dots += "."
                    }
                }
            }
            .padding(.horizontal,24)
        }
    }
}

#Preview {
    SearchResultScreen()
}
