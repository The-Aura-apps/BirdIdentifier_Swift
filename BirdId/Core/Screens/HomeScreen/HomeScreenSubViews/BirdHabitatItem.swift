//
//  HomeGridView.swift
//  BirdId
//
//  Created by ali bakhsha on 7/22/1404 AP.
//

import SwiftUI

struct BirdHabitatItem: View {
    
    @EnvironmentObject var coordinator: Coordinator
    let birdsHabitat = ["Grasslands", "Wetlands", "Woods", "Sea", "Mountains", "Desert"]
    
    let rows = [
        GridItem(.fixed(100)),
    ]
    
    var body: some View {
        ScrollView(.horizontal,showsIndicators: false){
            LazyHGrid(rows: rows,spacing: 16){
                ForEach(birdsHabitat,id: \.self){ birdsHabitat in
                    //TODO: Add Button
                    Button {
                        coordinator.push(.HabitatScreen(title: birdsHabitat))
                    } label: {
                        VStack {
                            Image(.grasslands)
                                .resizable()
                                .frame(width: 64,height: 64)
                                .scaledToFit()
                                .clipShape(Circle())
                                .padding(.bottom,8)
                            Text(birdsHabitat)
                                .font(.app(.Micro1))
                                .foregroundStyle(.text)
                        }
                    

                    }
                }
            }
            .padding(.leading,24)
            .padding(.trailing,24)
        }
    }
}

#Preview {
    BirdHabitatItem()
        .environmentObject(Coordinator())
}
