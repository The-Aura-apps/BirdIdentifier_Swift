//
//  BackButtonView.swift
//  BirdId
//
//  Created by ali bakhsha on 7/30/1404 AP.
//

import SwiftUI

struct BackButtonView: View {
    @EnvironmentObject var coordinator: Coordinator
    var customAction: (() -> Void)? = nil
    
    var body: some View {
        Button {
            if let customAction = customAction {
                customAction()
            } else {
                coordinator.pop()
            }
        } label: {
            Circle()
                .fill(Color.white.opacity(0.1))
                .overlay {
                    Image(.backButton)
                        .padding(.leading, 11)
                        .padding(.trailing, 13)
                }
                .adaptiveGlassEffect(style: .clear, cornerRadius: 99)
                .frame(width: UIScreen.screenWidth / 8.18, height: UIScreen.screenHeight / 17.75)
        }
    }
}

#Preview {
    BackButtonView()
        .environmentObject(Coordinator())
}
