//
//  SettingView.swift
//  BirdId
//
//  Created by ali bakhsha on 8/13/1404 AP.
//

import SwiftUI

struct SettingView: View {
    
    @State private var showPayment = false
    
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
                        .minimumScaleFactor(0.75)
                        .dynamicTypeSize(.small ... .xxLarge)
                    Spacer()
                }
                .padding(.vertical,24)
                
                //MARK: Poster Section
                //TODO: ...
                premiumPosterSection()
                
                //MARK: Links Section
                //TODO: ...
                linksSection()
                
                Spacer()
            }
            .padding(.horizontal,24)

        }
        .fullScreenCover(isPresented: $showPayment) {
            PaymentScreen()
        }
    }

}

extension SettingView {
    func premiumPosterSection() -> some View {
        Button(action: {
            showPayment.toggle()
        }, label: {
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
                                .minimumScaleFactor(0.75)
                                .dynamicTypeSize(.small ... .xxLarge)
                            Spacer()
                        }
                        .padding(.bottom,12)
                        HStack {
                            Text("Get faster, more accurate\nbird recognition and\nremove ads.")
                                .font(.app(.Micro2))
                                .foregroundStyle(Color(hex: "#194632"))
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                                .minimumScaleFactor(0.75)
                                .dynamicTypeSize(.small ... .xxLarge)
                            Spacer()
                        }
                        .padding(.bottom,20)
                        HStack {
                            Button(action: {
                                showPayment.toggle()
                            }, label: {
                                Text("Upgrade Now")
                                    .font(.app(.Sub3))
                                    .foregroundStyle(.text)
                                    .minimumScaleFactor(0.75)
                                    .dynamicTypeSize(.small ... .xxLarge)

                            })
                            .padding(.vertical,10)
                            .padding(.horizontal,24)
                            .adaptiveGlassEffect(style: .clear)
                            .frame(height: UIScreen.screenHeight / 20.78)
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(.horizontal,24)
//                    .ifAvailable{ view in
//                        view.adaptiveGlassEffect(style: .clear)
//                    }
                }
                .padding(.bottom,24)
        })

    }
    
    func linksSection() -> some View {
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
                    .frame(width: UIScreen.screenWidth - 48,height: UIScreen.screenHeight / 11.83)
                    .adaptiveGlassEffect(style: .clear, cornerRadius: 99)
                })
            }
        }
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
