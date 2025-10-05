//
//  OnboardingScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 7/9/1404 AP.
//

import SwiftUI

struct OnboardingScreen: View {
    @State private var step: OnboardingData = .firstPage
    @State private var rotation: Double = 0
    var body: some View {
        ZStack {
            step.backgroundImage.ignoresSafeArea()
            
            
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
    
    private func firstStep() -> some View {
        VStack{
            
            onboardingAppBar()
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
                step = step.next()
            } label: {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(height: 52)
                    .overlay {
                        Text("Get Started")
                            .font(.app(.Sub1))
                            .foregroundStyle(.text)
                        
                    }
                    .padding(.bottom,24)
            }
            
        }
        .padding(.horizontal,24)
    }
    
    private func secondStep() -> some View {
        VStack{
            onboardingAppBar()
                .padding(.bottom,40)
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
                        step = step.next()
                    } label: {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .frame(height: 52)
                            .overlay {
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
                                .padding(.horizontal,24)
                                
                            }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal,24)
    }
    
    private func thirdStep() -> some View {
        VStack{
            onboardingAppBar()
                .padding(.bottom,40)
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
                        step = step.next()
                    } label: {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .frame(height: 52)
                            .overlay {
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
                                .padding(.horizontal,24)
                                
                            }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal,24)
    }
    
    private func forthStep() -> some View {
        VStack{
            onboardingAppBar()
                .padding(.bottom,40)
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
            
            Image(.loading)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            Spacer()
        }
        .padding(.horizontal,24)
    }
    
    private func onboardingAppBar() -> some View {
        HStack(alignment: .center){
            if step != .firstPage {
                        Button {
                            step = step.back()
                        } label: {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 48, height: 48)
                                .overlay {
                                    Image(.backButton)
                                        .padding(.leading, 11)
                                        .padding(.trailing, 13)
                                }
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
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 24, height: 8)
                                        .overlay(
                                            Capsule().stroke(.ultraThinMaterial, lineWidth: 0.1)
                                        )
                                } else {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 8, height: 8)
                                        .overlay(
                                            Circle().stroke(.ultraThinMaterial, lineWidth: 0.1)
                                        )
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: step)
                        }
                    }
                    .frame(maxWidth: .infinity)
            
                    Color.clear
                        .frame(width: 48, height: 48)
        }
        .padding(.top,0)
    }
}
