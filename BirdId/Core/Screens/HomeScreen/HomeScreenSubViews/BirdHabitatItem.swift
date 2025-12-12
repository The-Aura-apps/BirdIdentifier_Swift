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
    
    let rows = [
        GridItem(.fixed(100)),
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 16) {
                if viewModel.isLoadingHabitats {
                    // Loading state
                    ForEach(0..<viewModel.habitats.count, id: \.self) { _ in
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
                } else if let error = viewModel.errorMessage {
                    // Error state
                    Text("Error: \(error)")
                        .font(.app(.Micro1))
                        .foregroundStyle(.red)
                        .padding()
                } else {
                    // Success state with actual data
                    ForEach(viewModel.habitats) { habitat in
                        Button {
                            coordinator.push(.HabitatScreen(title: habitat.name,description: habitat.description))
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
                            }
                        }
                    }
                }
            }
            .padding(.leading, 24)
            .padding(.trailing, 24)
        }
    }
}

#Preview {
    BirdHabitatItem(viewModel: HomeScreenViewModel())
        .environmentObject(Coordinator())
}
