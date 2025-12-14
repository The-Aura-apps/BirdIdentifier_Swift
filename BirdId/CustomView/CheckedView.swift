//
//  CheckedView.swift
//  BirdId
//
//  Created by ali bakhsha on 9/3/1404 AP.
//

import SwiftUI
import Lottie

enum CheckedState: Equatable {
    case success
    case failure
}

struct CheckedView: View {
    let checkedState: CheckedState
    
    var body: some View {
        ZStack{
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
            VStack{
                Spacer()
                LottieView(animationName: checkedState == .success ? "SuccessCheck" : "PerfectWrong",loopMode: .playOnce)
                    .frame(width: UIScreen.screenWidth / 2.62,height: UIScreen.screenHeight / 5.68)
                Spacer()
                Text(checkedState == .success ? "Bird identified!": "No match found. Try again.")
                    .font(.app(.Sub1))
                    .foregroundStyle(.text).opacity(0.8)
                    .padding(.bottom,32)
            }
        }
    }
}

#Preview {
    CheckedView(checkedState: .success)
}
