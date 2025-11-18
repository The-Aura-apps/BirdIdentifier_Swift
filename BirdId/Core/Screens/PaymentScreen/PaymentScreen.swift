//
//  PaymentScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/6/1404 AP.
//

import SwiftUI

struct PaymentScreen: View {
    
    @State private var selectedPlan: PlanType? = .discount
    @Environment(\.presentationMode) var presentationMode
    
    let plans: [PlanItem] = [
        PlanItem(type: .discount, title: "Yearly", price: "$199.99", discounted: "$39.99/year", badge: "-80% OFF"),
        PlanItem(type: .normal, title: "Weekly", price: "$7.99/week, auto renewable", discounted: nil, badge: nil),
        PlanItem(type: .free, title: "Free Plan", price: nil, discounted: nil, badge: "Free Trial")
    ]
    
    var body: some View {
        ZStack{
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
            
            VStack{
                // MARK: Header
                HStack(){
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 48, height: 48)
                            .overlay {
                                Image(systemName: "xmark")
                                    .padding(.all, 12)
                                    .foregroundStyle(.text)
                            }
                            .adaptiveGlassEffect(style: .clear,cornerRadius: 99)
                    }
                    Spacer()
                }
                // MARK: Animation
                LottieView(animationName: "PaymentAnimation")
                    .frame(width: UIScreen.screenWidth / 1.965,height: UIScreen.screenHeight / 4.26)
                    .padding(.bottom,16)
                Text("UNLOCK PREMIUM")
                    .font(.app(.Title1))
                    .foregroundStyle(.text)
                    .padding(.bottom,16)
                
                // MARK: Features
                VStack(alignment: .leading, spacing: 16) {
                    featureItem(image: .search, text: "Unlimited bird identifications")
                    featureItem(image: .crownMinimalistic, text: "Access to rare species database")
                    featureItem(image: .pulse, text: "Offline recognition mode")
                }
                .padding(.bottom,24)
                
                // MARK: Plans
                VStack(spacing: 16) {
                    ForEach(plans) { plan in
                        PlanOptionView(
                            type: plan.type,
                            title: plan.title,
                            price: plan.price,
                            discountedPrice: plan.discounted,
                            badgeText: plan.badge,
                            isSelected: selectedPlan == plan.type,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    selectedPlan = plan.type
                                }
                            }
                        )
                    }
                }
                .padding(.bottom,24)
                // MARK: Continue Button
                Button(action: {
                    
                }, label: {
                    Text("Continue")
                        .font(.app(.Sub1))
                        .foregroundStyle(.text)
                })
                .frame(maxWidth: .infinity)
                .padding(.vertical,14)
                .adaptiveGlassEffect(style: .clear,cornerRadius: 99)
                .padding(.bottom,8)
                
                HStack(spacing: 8) {
                    ForEach(["Restore", "Term of Use", "Privacy Policy"], id: \.self) { text in
                        Text(text)
                            .font(.app(.Micro1))
                            .foregroundStyle(.text)
                            .underline()
                    }
                }
            }
            .padding(24)
        }
        
        .navigationBarBackButtonHidden(true)

    }
}

extension PaymentScreen {
    
    private func featureItem(image: ImageResource, text: String) -> some View {
        HStack(spacing: 8) {
            Image(image)
                .frame(width: 20, height: 20)
            Text(text)
                .font(.app(.Sub1))
                .foregroundStyle(.text)
        }
    }
}

#Preview {
    PaymentScreen()
}


struct PlanItem: Identifiable {
    let id = UUID()
    let type: PlanType
    let title: String
    let price: String?
    let discounted: String?
    let badge: String?
}
