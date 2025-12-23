//
//  IdentifyBackButton.swift
//  BirdId
//
//  Created by ali bakhsha on 8/12/1404 AP.
//

import SwiftUI

struct IdentifyBackButton: View {
    @EnvironmentObject var coordinator: Coordinator
    @Binding var selectedTab: TabBarItem
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                if !coordinator.path.isEmpty {
                    coordinator.pop()
                } else {
                    selectedTab = .home
                }
            }
        } label: {
            Circle()
                .fill(Color.white.opacity(0.1))
                .overlay {
                    Image(.backButton)
                        .padding(.leading, 11)
                        .padding(.trailing, 13)
                }
                .adaptiveGlassEffect(style: .clear,cornerRadius: 99)
                .frame(width: UIScreen.screenWidth / 8.18, height: UIScreen.screenHeight / 17.75)
        }
    }
    }
#Preview {
    IdentifyBackButton(selectedTab: .constant(.home))
        .environmentObject(Coordinator())
}
