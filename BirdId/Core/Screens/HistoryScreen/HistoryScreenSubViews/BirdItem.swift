//
//  HistoryItem.swift
//  BirdId
//
//  Created by ali bakhsha on 8/20/1404 AP.
//

import SwiftUI

struct HistoryItem: View {
    @EnvironmentObject var coordinator: Coordinator
    
    let columns = [
        GridItem(.fixed(UIScreen.screenWidth / 2 - 24)),
        GridItem(.fixed(UIScreen.screenWidth / 2 - 24)),
    ]
    
    let mockObservations: [ObservationDetailResponse] = Array(repeating: .mock, count: 11)
    
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            LazyVGrid(columns: columns,spacing: 16){
                ForEach(Array(mockObservations.enumerated()), id: \.offset) { index, observation in
                    //TODO: Add Button
                    Button {
                        coordinator.push(.ResultScreen(observationDetail: observation))
                    } label: {
                        Image(.recordPoster)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity,maxHeight: UIScreen.screenHeight / 6.08)
                            .cornerRadius(28)
                            .overlay {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("Bird Name")
                                            .font(.app(.Micro1))
                                            .foregroundStyle(.text)
                                            .padding(.vertical,4)
                                            .padding(.horizontal,8)
                                            .adaptiveGlassEffect(style: .clear)
                                        Spacer()
                                    }
                                }
                                .padding(.vertical,12)
                                .padding(.horizontal,20)
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryItem()
        .environmentObject(Coordinator())
}
