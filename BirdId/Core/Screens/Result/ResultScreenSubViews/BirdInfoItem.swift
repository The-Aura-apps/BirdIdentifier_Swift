//
//  BirdInfoItem.swift
//  BirdId
//
//  Created by ali bakhsha on 8/9/1404 AP.
//

import SwiftUI

struct BirdInfoItem: View {
    @State private var selectedInfo: String?
    @State private var showFullDescription: Bool = false
    
    let birdsInfo  = ["Habit","Habitt","Habittt","Habi","Hab","Hbit","Hait","Habt",]
    
    let rows = [
        GridItem(.fixed(100)),
    ]
    
    init() {
        _selectedInfo = State(initialValue: "Habit")
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal,showsIndicators: false){
                LazyHGrid(rows: rows,spacing: 12) {
                    ForEach(birdsInfo,id: \.self) { info in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedInfo = info
                            }
                        }, label: {
                            Text(info)
                                .font(.app(.Micro1))
                                .foregroundStyle(selectedInfo == info ? Color(hex: "#BCB22A") : .text)
                                .padding(.horizontal,16)
                                .padding(.vertical,12)
                                .adaptiveGlassEffect(style: selectedInfo == info ? .regular : .clear)
                                .animation(.easeInOut(duration: 0.2), value: selectedInfo)
                        })
                        
                    }
                }
                .padding(.horizontal,24)
                .frame(height: 42)
            }
            .padding(.bottom,24)
            
            VStack(alignment: .leading,spacing: 16) {
                    Text(selectedInfo!)
                        .font(.app(.Headline4))
                        .foregroundStyle(.text)
                VStack (alignment: .leading,spacing: 0){
                    Text("Macaws are native to the southern portion of North America (Mexico) plus Central America and South America. Evidence shows that the Caribbean also had native macawMacaws are native to the southern portion of North America (Mexico) plus Central America and South America. Evidence shows that the Caribbean also had native macawMacaws are native to the southern portion of North America (Mexico) plus Central America and South America. Evidence shows that the Caribbean also had native macawMacaws are native to the southern portion of North America (Mexico) plus Central America and South America. Evidence shows that the Caribbean also had native macawMacaws are native to the southern portion of North America (Mexico) plus Central America and South America. Evidence shows that the Caribbean also had native macaw")
                        .lineLimit(showFullDescription ? nil : 3)
                        .font(.app(.Sub1))
                        .foregroundStyle(.text)
                        .multilineTextAlignment(.leading)
                    
                    
                    Button (action: {
                        withAnimation(.easeInOut) {
                            showFullDescription.toggle()
                        }
                    }, label: {
                        Text(showFullDescription ? "Less" : "Read more")
                            .font(.app(.Headline4))
                            .foregroundStyle(Color(hex: "#BCBCBC"))
                    })
                }

            }
            .padding(.bottom,16)
            .padding(.horizontal,24)
            
        }
//        .background(Color.blue)
    }
}

#Preview {
    BirdInfoItem()
}
