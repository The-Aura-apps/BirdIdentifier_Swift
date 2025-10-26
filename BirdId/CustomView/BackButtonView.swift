//
//  BackButtonView.swift
//  BirdId
//
//  Created by ali bakhsha on 7/30/1404 AP.
//

import SwiftUI

struct BackButtonView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
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
    BackButtonView()
}
