//
//  PlanOptionView.swift
//  BirdId
//
//  Created by ali bakhsha on 8/7/1404 AP.
//
enum PlanType {
    case normal
    case discount
    case free
}

import SwiftUI

struct PlanOptionView: View {
    let type: PlanType
    let title: String
    let price: String?
    let discountedPrice: String?
    let badgeText: String?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.app(.Headline4))
                        .foregroundStyle(.text)
                    
                    if type == .discount, let price, let discountedPrice {
                        HStack(spacing: 2) {
                            Text(price)
                                .font(.app(.Sub2))
                                .foregroundStyle(.strikeText)
                                .strikethrough()
                            Text(discountedPrice)
                                .font(.app(.Sub2))
                                .foregroundStyle(.text)
                        }
                    } else if type == .free {
                        Text("Free forever")
                            .font(.app(.Sub2))
                            .foregroundStyle(.text)
                    } else if let price {
                        Text(price)
                            .font(.app(.Sub2))
                            .foregroundStyle(.text)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    if type == .discount {
                        if let badgeText {
                            HStack {
                                Text(badgeText)
                                    .font(.app(.Micro2))
                                    .foregroundStyle(.text)
                            }
                            .padding(8)
                            .adaptiveGlassEffect(style: .clear, cornerRadius: 99)
                        }
                    }else if type == .free {
                        if let badgeText {
                            HStack {
                                Text(badgeText)
                                    .font(.app(.Micro2))
                                    .foregroundStyle(.text)
                            }
                            .padding(8)
                        }
                    }
                    
                    Circle()
                        .stroke(.text,lineWidth: isSelected ? 8 : 1)
                        .frame(width: isSelected ? 20 : 24, height:isSelected ? 20 : 24)
                    
                    
                    
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
            .adaptiveGlassEffect(style: .clear, cornerRadius: 99)
            .overlay(
                RoundedRectangle(cornerRadius: 99)
                    .stroke(isSelected ? Color.white.opacity(0.5) : .clear, lineWidth: 2)
            )
        }
    }
}


#Preview {
    VStack(spacing: 20) {
        PlanOptionView(
            type: .normal,
            title: "Monthly",
            price: "$9.99/month",
            discountedPrice: nil,
            badgeText: nil,
            isSelected: false,
            onTap: {}
        )
        
        PlanOptionView(
            type: .discount,
            title: "Yearly",
            price: "$199.99",
            discountedPrice: "$39.99/year",
            badgeText: "-80% OFF",
            isSelected: true,
            onTap: {}
        )
        
        PlanOptionView(
            type: .free,
            title: "Free Plan",
            price: nil,
            discountedPrice: nil,
            badgeText: "Free Trial",
            isSelected: false,
            onTap: {}
        )
    }
    .padding()
    .background(Color.black)
}

