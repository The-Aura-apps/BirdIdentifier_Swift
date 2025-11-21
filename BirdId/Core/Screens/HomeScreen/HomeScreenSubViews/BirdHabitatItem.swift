//
//  HomeGridView.swift
//  BirdId
//
//  Created by ali bakhsha on 7/22/1404 AP.
//

import SwiftUI

struct BirdHabitatItem: View {
    
    @EnvironmentObject var coordinator: Coordinator
    let birdsHabitat: [Habitat] = [
        .init(name: "Desert",image: .desert),
        .init(name: "Forest",image: .forest),
        .init(name: "Grassland",image: .grassland),
        .init(name: "Savanna",image: .savanna),
        .init(name: "Scrub",image: .scrub),
        .init(name: "Subterranean",image: .subterranean),
        .init(name: "Wetlands",image: .wetlands),
        .init(name: "Marine",image: .marine),
        ]
    
    let rows = [
        GridItem(.fixed(100)),
    ]
    
    var body: some View {
        ScrollView(.horizontal,showsIndicators: false){
            LazyHGrid(rows: rows,spacing: 16){
                ForEach(birdsHabitat,id: \.name){ birdsHabitat in
                    //TODO: Add Button
                    Button {
                        coordinator.push(.HabitatScreen(title: birdsHabitat.name))
                    } label: {
                        VStack {
                            Image(uiImage: birdsHabitat.image)
                                .resizable()
                                .frame(width: 64,height: 64)
                                .scaledToFit()
                                .clipShape(Circle())
                                .padding(.bottom,8)
                            Text(birdsHabitat.name)
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

struct Habitat {
    let name: String
    let image: UIImage
}

#Preview {
    BirdHabitatItem()
        .environmentObject(Coordinator())
}
