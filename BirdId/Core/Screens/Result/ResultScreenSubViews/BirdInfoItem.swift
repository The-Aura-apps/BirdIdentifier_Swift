//
//  BirdInfoItem.swift
//  BirdId
//
//  Created by ali bakhsha on 8/9/1404 AP.
//

import SwiftUI

struct BirdInfoItem: View {
    let birdDetail: BirdDetail?
    
    @State private var selectedInfo: BirdInfoType = .commonNames
    @State private var showFullDescription: Bool = false
    
    let rows = [
        GridItem(.fixed(100)),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            // Category Selection
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, spacing: 12) {
                    ForEach(BirdInfoType.allCases, id: \.self) { info in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedInfo = info
                                showFullDescription = false // Reset when switching tabs
                            }
                        }, label: {
                            Text(info.title)
                                .font(.app(.Micro1))
                                .foregroundStyle(selectedInfo == info ? Color(hex: "#BCB22A") : .text)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .adaptiveGlassEffect(style: selectedInfo == info ? .regular : .clear)
                                .animation(.easeInOut(duration: 0.2), value: selectedInfo)
                        })
                    }
                }
                .padding(.horizontal, 24)
                .frame(height: 42)
            }
            .padding(.bottom, 24)
            
            // Content Section
            if let birdDetail = birdDetail {
                makeContentSection(for: selectedInfo, birdDetail: birdDetail)
            } else {
                Text("No bird information available")
                    .font(.app(.Sub1))
                    .foregroundStyle(.text.opacity(0.6))
                    .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: - Content Builder
    @ViewBuilder
    private func makeContentSection(for type: BirdInfoType, birdDetail: BirdDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(type.title)
                .font(.app(.Headline4))
                .foregroundStyle(.text)
                .multilineTextAlignment(.leading)
            
            switch type {
            case .birdFoods:
                VStack(alignment: .leading, spacing: 16) {
                    if !birdDetail.birdFoods.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(birdDetail.birdFoods, id: \.name) { food in
                                VStack(alignment: .leading, spacing: 8) {
                                    // Header with food name
                                    HStack {
                                        Text(food.name)
                                            .font(.app(.Sub1))
                                            .foregroundStyle(.text)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                    }
                                    
                                    // Description
                                    Text(food.description)
                                        .font(.app(.Sub2))
                                        .foregroundStyle(.text.opacity(0.8))
                                        .multilineTextAlignment(.leading)
                                        .padding(.leading, 24)
                                }
                                .padding(.vertical, 12)
                            }
                        }
                    } else {
                        Text("No dietary information available")
                            .font(.app(.Sub1))
                            .foregroundStyle(.text.opacity(0.6))
                            .italic()
                    }
                }
                
            case .habitat:
                makeTextContent(birdDetail.habitats.joined(separator: ", "))
                
            case .behavior:
                makeExpandableText(birdDetail.behavior)
                
            case .description:
                makeExpandableText(birdDetail.description)
                
            case .feeding:
                VStack(alignment: .leading, spacing: 12) {
                    makeExpandableText(birdDetail.feedingHabits)
                    
                    if !birdDetail.birdFoods.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Diet")
                                .font(.app(.Headline4))
                                .foregroundStyle(.text)
                                .padding(.top, 8)
                            
                            ForEach(birdDetail.birdFoods, id: \.name) { food in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("• \(food.name)")
                                        .font(.app(.Sub1))
                                        .foregroundStyle(.text)
                                        .fontWeight(.semibold)
                                    
                                    Text(food.description)
                                        .font(.app(.Sub2))
                                        .foregroundStyle(.text.opacity(0.8))
                                        .padding(.leading, 12)
                                }
                            }
                        }
                    }
                }
                
            case .nesting:
                VStack(alignment: .leading, spacing: 12) {
                    makeExpandableText(birdDetail.nestingHabits)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Eggs")
                            .font(.app(.Headline4))
                            .foregroundStyle(.text)
                            .padding(.top, 8)
                        
                        makeTextContent(birdDetail.eggsDescription)
                    }
                }
                
            case .distribution:
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(birdDetail.distributions.prefix(5), id: \.month) { dist in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(monthName(dist.month))
                                    .font(.app(.Sub1))
                                    .foregroundStyle(.text)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text(dist.season.capitalized)
                                    .font(.app(.Micro1))
                                    .foregroundStyle(Color(hex: "#BCB22A"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .adaptiveGlassEffect(style: .clear)
                            }
                            
                            Text(dist.location.region + ", " + dist.location.country)
                                .font(.app(.Sub2))
                                .foregroundStyle(.text.opacity(0.8))
                            
                            Text(dist.description)
                                .font(.app(.Sub2))
                                .foregroundStyle(.text.opacity(0.7))
                                .padding(.top, 2)
                        }
                        .padding(.vertical, 8)
                        
                        if dist.month != birdDetail.distributions.prefix(5).last?.month {
                            Divider()
                                .background(.text.opacity(0.2))
                        }
                    }
                }
                
            case .taxonomy:
                VStack(alignment: .leading, spacing: 8) {
                    makeTaxonomyRow("Genus", birdDetail.taxonomy.genus)
                    makeTaxonomyRow("Family", birdDetail.taxonomy.family)
                    makeTaxonomyRow("Order", birdDetail.taxonomy.order)
                    makeTaxonomyRow("Class", birdDetail.taxonomy.class)
                    makeTaxonomyRow("Phylum", birdDetail.taxonomy.phylum)
                }
                
            case .conservation:
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(birdDetail.conservationStatus.fullName)
                            .font(.app(.Headline4))
                            .foregroundStyle(conservationColor(birdDetail.conservationStatus.severityLevel))
                        
                        Spacer()
                        
                        Text(birdDetail.conservationStatus.code)
                            .font(.app(.Micro1))
                            .foregroundStyle(.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .adaptiveGlassEffect(style: .clear)
                    }
                    
                    Text("Authority: \(birdDetail.conservationStatus.authority)")
                        .font(.app(.Sub2))
                        .foregroundStyle(.text.opacity(0.8))
                    
                    makeTextContent(birdDetail.conservationStatus.description)
                }
                
            case .commonNames:
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(birdDetail.commonNames, id: \.name) { commonName in
                        HStack {
                            Text(commonName.name)
                                .font(.app(.Sub1))
                                .foregroundStyle(.text)
                            
                            Spacer()
                            
                            Text("\(commonName.region) (\(commonName.language))")
                                .font(.app(.Micro1))
                                .foregroundStyle(.text.opacity(0.7))
                        }
                        .padding(.vertical, 4)
                    }
                }
                
            case .coolFacts:
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(birdDetail.coolFacts.enumerated()), id: \.offset) { index, fact in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .font(.app(.Sub1))
                                .foregroundStyle(Color(hex: "#BCB22A"))
                                .fontWeight(.bold)
                            
                            Text(fact)
                                .font(.app(.Sub1))
                                .foregroundStyle(.text)
                        }
                    }
                }
                
            case .size:
                VStack(alignment: .leading, spacing: 12) {
                    makeSizeRow("Length", min: birdDetail.size.lengthCm.min, max: birdDetail.size.lengthCm.max, unit: "cm")
                    makeSizeRow("Wingspan", min: birdDetail.size.wingspanCm.min, max: birdDetail.size.wingspanCm.max, unit: "cm")
                    makeSizeRow("Weight", min: birdDetail.size.weightGrams.min, max: birdDetail.size.weightGrams.max, unit: "g")
                    
                    Text("Life Expectancy: ~\(birdDetail.lifeExpectancyYears) years")
                        .font(.app(.Sub1))
                        .foregroundStyle(.text)
                        .padding(.top, 8)
                }
            }
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Helper Views
    @ViewBuilder
    private func makeExpandableText(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .lineLimit(showFullDescription ? nil : 3)
                .font(.app(.Sub1))
                .foregroundStyle(.text)
                .multilineTextAlignment(.leading)
            
            if text.count > 150 {
                Button(action: {
                    withAnimation(.easeInOut) {
                        showFullDescription.toggle()
                    }
                }, label: {
                    Text(showFullDescription ? "Less" : "Read more")
                        .font(.app(.Headline4))
                        .foregroundStyle(Color(hex: "#BCBCBC"))
                })
                .padding(.top, 4)
            }
        }
    }
    
    @ViewBuilder
    private func makeTextContent(_ text: String) -> some View {
        Text(text)
            .font(.app(.Sub1))
            .foregroundStyle(.text)
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    private func makeTaxonomyRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.app(.Sub1))
                .foregroundStyle(.text.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.app(.Sub1))
                .foregroundStyle(.text)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func makeSizeRow(_ label: String, min: Double, max: Double, unit: String) -> some View {
        HStack {
            Text(label)
                .font(.app(.Sub1))
                .foregroundStyle(.text)
            
            Spacer()
            
            Text("\(min, specifier: "%.1f") - \(max, specifier: "%.1f") \(unit)")
                .font(.app(.Sub1))
                .foregroundStyle(.text)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Helper Functions
    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(month: month))!
        return formatter.string(from: date)
    }
    
    private func conservationColor(_ severity: Int) -> Color {
        switch severity {
        case 1...2: return .red
        case 3...4: return Color(hex: "#BCB22A")
        case 5...6: return .green
        default: return .text
        }
    }
}

// MARK: - Bird Info Types
enum BirdInfoType: String, CaseIterable {
    case commonNames = "Common Names"
    case size = "Size & Lifespan"
    case description = "Description"
    case habitat = "Habitat"
    case birdFoods = "BirdFoods"
    case behavior = "Behavior"
    case feeding = "Feeding"
    case nesting = "Nesting"
    case distribution = "Distribution"
    case taxonomy = "Taxonomy"
    case conservation = "Conservation"
    case coolFacts = "Cool Facts"
    
    
    var title: String {
        return self.rawValue
    }
}

#Preview {
    ScrollView {
        BirdInfoItem(birdDetail: BirdDetail(
            size: BirdSize(
                lengthCm: SizeRange(max: 30, min: 22),
                wingspanCm: SizeRange(max: 43, min: 34),
                weightGrams: SizeRange(max: 100, min: 70)
            ),
            behavior: "Blue jays are known for their intelligence and complex social behaviors.",
            habitats: ["Forest", "Grassland", "Scrub"],
            taxonomy: Taxonomy(
                id: 3,
                phylum: "Chordata",
                class: "Aves",
                order: "Passeriformes",
                family: "Corvidae",
                genus: "Cyanocitta",
                createdAt: nil,
                updatedAt: nil
            ),
            birdFoods: [
                BirdFood(name: "Seeds", description: "Various seeds including sunflower"),
                BirdFood(name: "Insects", description: "Caterpillars and beetles")
            ],
            coolFacts: [
                "Blue jays can mimic hawk calls",
                "They can recognize human faces"
            ],
            commonNames: [
                CommonName(name: "Blue Jay", region: "North America", language: "en")
            ],
            description: "A striking medium-sized bird with vibrant blue plumage.",
            distributions: [],
            feedingHabits: "Omnivorous with diverse diet",
            nestingHabits: "Nests in trees using twigs and grass",
            scientificName: "Cyanocitta cristata",
            eggsDescription: "Pale blue eggs with brown speckles",
            conservationStatus: ConservationStatus(
                id: 1,
                code: "LC",
                fullName: "Least Concern",
                authority: "IUCN",
                description: "Stable population",
                severityLevel: 3,
                createdAt: nil,
                updatedAt: nil
            ),
            lifeExpectancyYears: 7
        ))
    }
    .background(Color(hex: "#5B765C"))
}
