//
//  HomeGridView.swift
//  BirdId
//
//  Created by ali bakhsha on 7/22/1404 AP.
//

import SwiftUI

struct BirdHabitatItem: View {
    
    @EnvironmentObject var coordinator: Coordinator
    @ObservedObject var viewModel: HomeScreenViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if viewModel.isLoadingHabitats {
                // Loading state
                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        VStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 64, height: 64)
                                .padding(.bottom, 8)
                            Text("Loading...")
                                .font(.app(.Micro1))
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding(.horizontal, 24)
            } else if let error = viewModel.errorMessage {
                // Error state
                Text("Error: \(error)")
                    .font(.app(.Micro1))
                    .foregroundStyle(.red)
                    .padding()
            } else {
                HStack(spacing: 16) {
                    ForEach(viewModel.habitats) { habitat in
                        Button {
                            coordinator.push(.HabitatScreen(
                                habitatId: habitat.id,
                                title: habitat.name,
                                description: habitat.description
                            ))
                        } label: {
                            VStack {
                                Image(viewModel.getHabitatImage(for: habitat.name))
                                    .resizable()
                                    .frame(width: 64, height: 64)
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .padding(.bottom, 8)
                                Text(habitat.name)
                                    .font(.app(.Micro1))
                                    .foregroundStyle(.text)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 70)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

#Preview {
    BirdHabitatItem(viewModel: HomeScreenViewModel())
        .environmentObject(Coordinator())
}
