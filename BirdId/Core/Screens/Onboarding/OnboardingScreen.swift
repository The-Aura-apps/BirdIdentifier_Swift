//
//  OnboardingScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 7/9/1404 AP.
//

import SwiftUI
import Lottie

struct OnboardingScreen: View {
    @State private var step: OnboardingData = .firstPage
    @State private var selectedAnswers: [OnboardingData: Int] = [:]
    var body: some View {
        ZStack {
            step.backgroundImage.resizable().ignoresSafeArea()
            
            
            currentStepContent()
        }
        }
    }


#Preview {
    OnboardingScreen()
}


extension OnboardingScreen {
    @ViewBuilder
    private func currentStepContent() -> some View {
        
        VStack {
            onboardingAppBar()
                .padding(.bottom,40)
            Group{
                switch step {
                case .firstPage:
                    firstStep()
                case .secondPage:
                    secondStep()
                case .thirdPage:
                    thirdStep()
                case .forthPage:
                    forthStep()
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: step)
        }
        .padding(.horizontal,24)
    }
    
    private func firstStep() -> some View {
        VStack{
            Spacer()
            Image(.onboardingLogo)
                .frame(height: 324)
                .padding(.bottom,40)
            
            Text(step.mainText)
                .font(.app(.Headline1))
                .foregroundStyle(.text)
                .padding(.bottom,24)
            
            Text(step.secondaryText)
                .font(.app(.Headline3))
                .foregroundStyle(.text)
                .padding(.bottom,24)
            
            Text(step.bodyText)
                .font(.app(.Sub1))
                .multilineTextAlignment(.center)
                .foregroundStyle(.text)
                .padding(.bottom,24)
            
            Spacer()
            
            Button {
                withAnimation {
                    step = step.next()
                }
                
            } label: {
                HStack {
                    Text("Get Started")
                        .font(.app(.Sub1))
                        .foregroundStyle(.text)
                }
                .frame(width: UIScreen.screenWidth - 48, height: 52)
                .adaptiveGlassEffect(style: .clear)
            }
            Spacer()
        }
    }
    
    private func secondStep() -> some View {
        VStack{
            HStack {
                Text(step.questions)
                    .font(.app(.Headline2))
                    .foregroundStyle(.text)
                Spacer()
            }
            .padding(.bottom,40)
            
            VStack(spacing: 24) {
                ForEach(0..<step.answer.count,id: \.self) { index in
                    Button {
                        selectedAnswers[step] = index
                        withAnimation {
                            step = step.next()
                        }
                    } label: {
                        HStack {
                            if let image = step.answer[index].0 {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            Text(step.answer[index].1)
                                .font(.app(.Sub1))
                                .foregroundStyle(.text)
                            Spacer()
                        }
                        .frame(height: 52)
                        .padding(.horizontal,24)
                        .adaptiveGlassEffect(style: selectedAnswers[step] == index ? .regular : .clear)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private func thirdStep() -> some View {
        VStack{
            HStack {
                Text(step.questions)
                    .font(.app(.Headline2))
                    .foregroundStyle(.text)
                Spacer()
            }
            .padding(.bottom,40)
            
            VStack(spacing: 24) {
                ForEach(0..<step.answer.count,id: \.self) { index in
                    Button {
                        selectedAnswers[step] = index
                        withAnimation {
                            step = step.next()
                        }
                    } label: {
                        HStack {
                            if let image = step.answer[index].0 {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            Text(step.answer[index].1)
                                .font(.app(.Sub1))
                                .foregroundStyle(.text)
                            Spacer()
                        }
                        .frame(height: 52)
                        .padding(.horizontal,24)
                        .adaptiveGlassEffect(style: selectedAnswers[step] == index ? .regular : .clear)

                    }
                }
            }
            
            Spacer()
        }
    }
    
    private func forthStep() -> some View {
        VStack{
            Image(.onboardingLogo)
                .frame(height: 324)
                .padding(.bottom,40)
            
            Text(step.mainText)
                .font(.app(.Headline1))
                .foregroundStyle(.text)
                .multilineTextAlignment(.center)
                .padding(.bottom,24)
            
            Text(step.bodyText)
                .font(.app(.Sub1))
                .multilineTextAlignment(.center)
                .foregroundStyle(.text)
            Spacer()
            
            LottieView(animationName: "OnboadingLoading")
                .frame(width: 60, height: 60)
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")

            }
        }
    }
    
    private func onboardingAppBar() -> some View {
        HStack(alignment: .center){
            if step != .firstPage {
                        Button {
                            withAnimation {
                                step = step.back()
                            }
                        } label: {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 48, height: 48)
                                .overlay {
                                    Image(.backButton)
                                        .padding(.leading, 11)
                                        .padding(.trailing, 13)
                                }
                                .adaptiveGlassEffect(style: .clear,cornerRadius: 99)
                        }
                    } else {
                        Color.clear
                            .frame(width: 48, height: 48)
                    }
            Spacer()
            
            HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { index in
                            ZStack {
                                if index == step.id - 1 {
                                    Capsule()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 24, height: 8)
                                        .adaptiveGlassEffect(style: .clear)
                                } else {
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 8, height: 8)
                                        .adaptiveGlassEffect(style: .clear)
                                }
                            }
                            .animation(.easeInOut, value: step)
                        }
                    }
                    .frame(maxWidth: .infinity)
            
                    Color.clear
                        .frame(width: 48, height: 48)
        }
        .padding(.top,0)
    }
}
