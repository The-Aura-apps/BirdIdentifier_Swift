//
//  SplashScreen.swift
//  BirdId
//
//  Created by ali bakhsha.
//

import SwiftUI

struct SplashScreen: View {

    var onFinished: () -> Void

    // MARK: - State
    @State private var showText = false
    @State private var logoScale: CGFloat = 0.92

    // MARK: - Config
    private let splashGreen = Color(hex: "#5B765C")
    private let lottieName = "OnboadingLoading"
    private let displayDuration: TimeInterval = 2.6

    var body: some View {
        ZStack {
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                LottieView(
                    animationName: lottieName,
                    animationSpeed: 1.0
                )
                .frame(width: 240, height: 240)
                .scaleEffect(logoScale)
                Spacer()

                VStack(spacing: 6) {
                    Text("Aura App")
                        .font(.app(.Sub2))
                        .foregroundStyle(.text.opacity(0.85))
                }
                .opacity(showText ? 1 : 0)
                .offset(y: showText ? 0 : 14)
            }
        }
        .task {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                logoScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                showText = true
            }

            try? await Task.sleep(nanoseconds: UInt64(displayDuration * 1_000_000_000))
            onFinished()
        }
    }
}

#Preview {
    SplashScreen(onFinished: {})
}
