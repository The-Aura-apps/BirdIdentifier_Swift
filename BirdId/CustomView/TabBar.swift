//
//  TabBar.swift
//  BirdId
//
//  Created by ali bakhsha on 7/20/1404 AP.
//

import Foundation
import SwiftUI

struct CustomTabBar: View {
    @Namespace var animation
    @Binding var selectedTab: TabBarItem
//    @EnvironmentObject var coordinator: Coordinator
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                Spacer()
                tabButton(.home)
                Spacer()
                tabButton(.identify)
                Spacer()
                tabButton(.history)
                Spacer()
                tabButton(.setting)
                Spacer()
            }
            .frame(height: UIScreen.screenHeight / 13.3)
            .adaptiveGlassEffect(style: .clear, cornerRadius: 0)
        }
        .ignoresSafeArea(.keyboard)
        .frame(maxWidth: UIScreen.screenWidth - 48, alignment: .bottom)
        .cornerRadius(99)
    }
    
    @ViewBuilder
    private func tabButton(_ tab: TabBarItem) -> some View {
        Button {
            withAnimation(.easeInOut) {
                    selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                tab.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .opacity(1.0)
                
                Text(tab.label)
                    .font(.app(.Micro1))
                    .foregroundStyle(.text)
                
            }
            .padding(.horizontal,8)
            .padding(.vertical,4)
            .adaptiveGlassEffect(style: selectedTab == tab ? .regular : .identity,cornerRadius: 16)
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.home))
}


enum TabBarItem : Hashable {
    case home
    case identify
    case history
    case setting
    
    
    var image : Image {
        switch self {
        case .home:
            return Image(.home)
        case .identify:
            return Image(.identifyBird)
        case .history:
            return Image(.book)
        case .setting:
            return Image(.setting)
        }
    }
    
    var label : String {
        switch self {
        case .home:
            return "Home"
        case .identify:
            return "Identify"
        case .history:
            return "history"
        case .setting:
            return "setting"
        }
    }
}
