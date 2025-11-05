//
//  SettingView.swift
//  BirdId
//
//  Created by ali bakhsha on 8/13/1404 AP.
//

import SwiftUI

struct SettingView: View {
    let options: [OptionItem] = [
        OptionItem(icon: .privacyPolicy, title: "Privacy & Policy",url: URL(string: "https://www.google.com")!),
        OptionItem(icon: .termsOfUse, title: "Terms of Use",url: URL(string: "https://www.google.com")!),
        OptionItem(icon: .contactUs, title: "Contact US",url: URL(string: "https://www.google.com")!),
        OptionItem(icon: .rate, title: "Rate Us",url: URL(string: "https://www.google.com")!)
    ]
    var body: some View {
        ZStack{
            Image(.bgImg)
                .resizable().ignoresSafeArea()
            VStack{
                HStack {
                    Text("Setting")
                        .font(.app(.Headline1))
                        .foregroundStyle(.text)
                    Spacer()
                }
                .padding(.vertical,24)
                
                premiumPosterSection()
                
                VStack(spacing: 16) {
                    ForEach(options) { option in
                        Button(action: {
                            //MARK: open links
                            UIApplication.shared.open(option.url)
                        }, label: {
                            HStack {
                                Image(uiImage: option.icon)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding(.trailing, 12)
                                Text(option.title)
                                    .font(.app(.Headline4))
                                    .foregroundStyle(.text)
                                Spacer()
                                Image(.squareTopDown)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            .padding(.all, 24)
                            .frame(width: UIScreen.screenWidth - 48)
                            .adaptiveGlassEffect(style: .clear, cornerRadius: 99)
                        })
//                        .buttonStyle(PlainButtonStyle())
                    }
                }
                Spacer()
            }
            .padding(.horizontal,24)
        }
    }
}

extension SettingView {
    func premiumPosterSection() -> some View {
        Image(.premiumPoster)
            .resizable()
            .frame(width: UIScreen.screenWidth - 48,height: UIScreen.screenHeight / 4.4)
            .overlay {
                VStack{
                    Spacer()
                    HStack {
                        Text("Try Premium Features")
                            .font(.app(.Headline5))
                            .foregroundStyle(Color(hex: "#194632"))
                        Spacer()
                    }
                    .padding(.bottom,12)
                    HStack {
                        Text("Get faster, more accurate\nbird recognition and\nremove ads.")
                            .font(.app(.Micro2))
                            .foregroundStyle(.text)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.bottom,20)
                    HStack {
                        Button(action: {

                        }, label: {
                            Text("Upgrade Now")
                                .font(.app(.Sub3))
                                .foregroundStyle(.text)

                        })
                        .padding(.vertical,10)
                        .padding(.horizontal,24)
                        .adaptiveGlassEffect(style: .clear)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.horizontal,24)
                .adaptiveGlassEffect(style: .clear)
            }
            .padding(.bottom,24)
    }
}


#Preview {
    SettingView()
}


struct OptionItem: Identifiable {
    let id = UUID()
    let icon: UIImage
    let title: String
    let url: URL
}
