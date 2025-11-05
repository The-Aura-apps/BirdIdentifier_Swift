//
//  IdentifyBackButton.swift
//  BirdId
//
//  Created by ali bakhsha on 8/12/1404 AP.
//

import SwiftUI

struct IdentifyBackButton: View {
    @Binding var selectedTab: TabBarItem
    
    var body: some View {
        Button {
            withAnimation(.easeInOut){
                selectedTab = .home
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
    }
    }
#Preview {
    IdentifyBackButton(selectedTab: .constant(.home))
}
