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
    @State var showOfflineMode = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                Spacer()
                tabButton(.home)
                Spacer()
                Spacer()
                Spacer()
                tabButton(.history)
                Spacer()

            }
            .frame(height: UIScreen.screenHeight / 13.3)
            .glassEffect(Glass.clear,in: Rectangle())
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedTab = .identify
                }
            } label: {
                ZStack {
                    Circle()
                        .frame(width: 64, height: 64)
                        .glassEffect(Glass.clear)
                    
                    TabBarItem.identify.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .offset(y: -32)
        
        }
        .ignoresSafeArea(.keyboard)
        .frame(maxWidth: UIScreen.screenWidth, alignment: .bottom)
        .ignoresSafeArea(edges: .bottom)
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
                    .opacity(selectedTab == tab ? 1.0 : 0.5)
                
                if selectedTab == tab {
                    Rectangle()
                        .fill(.white.opacity(0.8))
                        .frame(width: 40, height: 2)
                        .cornerRadius(1)
                        .transition(.opacity)
                } else {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 40, height: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CustomTabBar( selectedTab: .constant(.home))
}



enum TabBarItem : Hashable {
    case home
    case identify
    case history
    
    
    var image : Image {
        switch self {
        case .home:
            return Image(.home)
        case .identify:
            return Image(.camera)
        case .history:
            return Image(.book)
        }
    }
}
