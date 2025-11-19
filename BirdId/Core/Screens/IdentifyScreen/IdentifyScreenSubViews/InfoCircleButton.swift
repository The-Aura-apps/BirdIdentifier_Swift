//
//  InfoCircleButton.swift
//  BirdId
//
//  Created by ali bakhsha on 7/30/1404 AP.
//

import SwiftUI

struct InfoCircleButton: View {
    @State private var isActive: Bool = false
    
    var body: some View {
        Button {
            //TODO:
            isActive.toggle()
        } label: {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(.questionFilled)
                        .padding(.all, 12)
                }
                .adaptiveGlassEffect(style: .clear,cornerRadius: 99)
        }
        .sheet(isPresented: $isActive) {
            VStack{
                HStack{
                    Button(action: {
                        isActive.toggle()
                    }, label: {
                        Image(systemName: "xmark")
                            .frame(width: 24,height: 24)
                            .foregroundStyle(.dark)
                    })
                    
                    Spacer()
                    
                    Text("Snap Tips")
                        .foregroundStyle(.dark)
                        .font(.app(.Headline1))
                    
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .frame(width: 24, height: 24)
                        .opacity(0)
                }
                .padding(.bottom,24)
                
                Text("Center your bird and tap the button to\ncapture")
                    .font(.app(.Sub2))
                    .foregroundStyle(Color(hex: "#6B6B6B"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom,40)
                
                
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.background)
                        .frame(width: UIScreen.screenWidth / 2.46,height: UIScreen.screenHeight / 5.325)
                        .overlay {
                            Image(.okImg)
                                .resizable()
                                .scaledToFit()
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0) )
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(.dark.opacity(0.1), lineWidth: 1)
                        )
                        .overlay(
                            Image(.tickMark)
                                .frame(width: 40,height: 40)
                                .offset(x: 16,y: -16),
                            alignment: .topTrailing
                        )
                        .padding(.bottom,40)
                
                HStack{
                    Spacer()
                    VStack(alignment: .center){
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.background)
                            .frame(width: UIScreen.screenWidth / 4.9125,height: UIScreen.screenHeight / 10.65)

                            .overlay {
                                Image(.okImg)
                                    .resizable()
                                    .scaleEffect(2)
                                    .scaledToFit()
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0) )
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(.dark.opacity(0.1), lineWidth: 1)

                            )
                            .cornerRadius(24)
                            .padding(.bottom,8)
                        
                        HStack(spacing: 0) {
                            Text("Too close ")
                                .font(.app(.Micro1))
                                .foregroundStyle(Color(hex: "#6B6B6B"))
                                .multilineTextAlignment(.center)
                            Image(.closeIcon)
                                .frame(width: 18, height: 18)
                        }

                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                    VStack(alignment: .center){
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.background)
                            .frame(width: UIScreen.screenWidth / 4.9125,height: UIScreen.screenHeight / 10.65)

                            .overlay {
                                Image(.multiples)
                                    .resizable()
//                                    .scaleEffect(2)
                                    .scaledToFit()
//                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0) )
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(.dark.opacity(0.1), lineWidth: 1)

                            )
                            .cornerRadius(24)
                            .padding(.bottom,8)
                        
                        HStack(spacing: 0) {
                            Text("Multiples ")
                                .font(.app(.Micro1))
                                .foregroundStyle(Color(hex: "#6B6B6B"))
                                .multilineTextAlignment(.center)
                            Image(.closeIcon)
                                .frame(width: 18, height: 18)
                        }

                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                    VStack(alignment: .center){
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.background)
                            .frame(width: UIScreen.screenWidth / 4.9125,height: UIScreen.screenHeight / 10.65)

                            .overlay {
                                Image(.okImg)
                                    .resizable()
                                    .scaleEffect(0.7)
                                    .scaledToFit()
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0) )
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(.dark.opacity(0.1), lineWidth: 1)

                            )
                            .cornerRadius(24)
                            .padding(.bottom,8)
                        
                        HStack(spacing: 0) {
                            Text("Too far ")
                                .font(.app(.Micro1))
                                .foregroundStyle(Color(hex: "#6B6B6B"))
                                .multilineTextAlignment(.center)
                            Image(.closeIcon)
                                .frame(width: 18, height: 18)
                        }

                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                

                
                Spacer()
            }
            .padding(.horizontal,24)
            .padding(.vertical,48)
            .presentationBackground(Color.white)
            .presentationDetents([.height(UIScreen.screenHeight / 1.38)])
        }
    }
}

#Preview {
    InfoCircleButton()
}
