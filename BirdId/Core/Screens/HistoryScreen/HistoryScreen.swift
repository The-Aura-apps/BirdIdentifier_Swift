//
//  HistoryScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/20/1404 AP.
//

import SwiftUI

struct HistoryScreen: View {
    @StateObject private var viewModel = HistoryViewModel()
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        ZStack {
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Text("Records")
                        .font(.app(.Headline1))
                        .foregroundStyle(.text)
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                
                // Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.text)
                    Spacer()
                } else if viewModel.birds.isEmpty {
                    EmptyHistoryView()
                } else {
                    ScrollView(showsIndicators: false) {
                        HistoryItem(birds: viewModel.birds)
                            .padding(.bottom, UIScreen.screenHeight / 13.3)
                            .padding(.bottom, 32)
                    }
//                    .padding(.horizontal, 24)
                }
            }
        }
//        .padding(.horizontal,24)
        .onAppear {
            if viewModel.birds.isEmpty {
                viewModel.loadHistory()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("Retry") {
                viewModel.retry()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}

// MARK: - Empty State View
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bird.fill")
                .font(.app(.Headline1))
                .foregroundStyle(.text)
            
            Text("No Records Yet")
                .font(.app(.Headline2))
                .foregroundStyle(.text)
            
            Text("Start identifying birds to see them here")
                .font(.app(.Headline3))
                .foregroundStyle(.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

#Preview {
    HistoryScreen()
        .environmentObject(Coordinator())
}
