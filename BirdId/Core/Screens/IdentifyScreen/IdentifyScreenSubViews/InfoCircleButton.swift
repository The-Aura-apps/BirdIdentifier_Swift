//
//  InfoCircleButton.swift
//  BirdId
//
//  Created by ali bakhsha on 7/30/1404 AP.
//

import SwiftUI

struct InfoCircleButton: View {
    var body: some View {
        Button {
            //TODO:
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
    }
}

#Preview {
    InfoCircleButton()
}
