//
//  BirdInfoItem.swift
//  BirdId
//
//  Created by ali bakhsha on 8/9/1404 AP.
//


import SwiftUI

struct BirdInfoItem: View {
    let birdDetail: BirdDetailResponse
    
    // Convenience init for backward compatibility
    init(uploadResponse: UploadResponse) {
        self.birdDetail = uploadResponse.bird
    }
    
    // Direct init with BirdDetailResponse
    init(birdDetail: BirdDetailResponse) {
        self.birdDetail = birdDetail
    }
    
    @State private var selectedInfo: BirdInfoType = .commonNames
    @State private var showFullDescription:  Bool = false
    
    let rows = [
        GridItem(.fixed(100)),
    ]
    
    var body:  some View {
        VStack(alignment: .leading) {
            // Category Selection
            ScrollView(. horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, spacing: 12) {
                    ForEach(BirdInfoType.allCases, id: \.self) { info in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedInfo = info
                                showFullDescription = false
                            }
                        }, label: {
                            Text(info.title)
                                .font(.app(. Micro1))
                                .foregroundStyle(selectedInfo == info ? Color(hex: "#BCB22A") : .text)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .adaptiveGlassEffect(style:  selectedInfo == info ? .regular : .clear)
                                .animation(.easeInOut(duration: 0.2), value: selectedInfo)
                        })
                    }
                }
                .padding(.horizontal, 24)
                .frame(height: 42)
            }
            . padding(.bottom, 24)
            
            // Content Section
            makeContentSection(for: selectedInfo)
        }
    }
    
    // ...  rest of your existing code remains the same
    
    // MARK: - Content Builder
    @ViewBuilder
    private func makeContentSection(for type: BirdInfoType) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(type.title)
                .font(.app(.Headline4))
                .foregroundStyle(. text)
                .multilineTextAlignment(.leading)
            
            switch type {
            case .birdFoods:
                if !birdDetail.birdFoods.isEmpty {
                    ForEach(birdDetail.birdFoods, id: \.food.id) { wrapper in
                        let food = wrapper.food
                        VStack(alignment: .leading, spacing: 8) {
                            Text(food.name)
                                .font(.app(.Sub1))
                                .foregroundStyle(.text)
                                .fontWeight(.semibold)
                            Text(food.description ??  "No additional information available")
                                .font(.app(.Sub2))
                                .foregroundStyle(.text.opacity(0.8))
                                .padding(.leading, 24)
                        }
                        .padding(.vertical, 12)
                    }
                } else {
                    Text("No dietary information available")
                        .font(.app(.Sub1))
                        .foregroundStyle(.text.opacity(0.6))
                        .italic()
                }
                
            case .habitat:
                if !birdDetail.habitats.isEmpty {
                    ForEach(birdDetail.habitats, id: \.id) { habitat in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(habitat.name)
                                .font(.app(.Sub1))
                                .foregroundStyle(. text)
                                .fontWeight(.semibold)
                            
                            if let description = habitat.description, !description.isEmpty {
                                Text(description)
                                    .font(.app(.Sub2))
                                    .foregroundStyle(.text.opacity(0.8))
                                    .padding(. leading, 24)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                } else {
                    Text("No habitat information available yet")
                        .font(.app(.Sub1))
                        . foregroundStyle(.text.opacity(0.6))
                        . italic()
                }
                
            case .behavior:
                makeExpandableText(birdDetail.behavior  ?? "No additional information available")
                
            case .description:
                makeExpandableText(birdDetail.description  ?? "No additional information available")
                
            case .feeding:
                VStack(alignment: .leading, spacing: 12) {
                    makeExpandableText(birdDetail.feedingHabits  ?? "No additional information available")
                    if !birdDetail.birdFoods.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Diet")
                                .font(.app(. Headline4))
                                .foregroundStyle(.text)
                                .padding(.top, 8)
                            ForEach(birdDetail.birdFoods, id: \.food.id) { wrapper in
                                let food = wrapper.food
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("• \(food.name)")
                                        .font(.app(. Sub1))
                                        . foregroundStyle(.text)
                                        .fontWeight(.semibold)
                                    Text(food.description  ?? "No additional information available")
                                        .font(.app(. Sub2))
                                        . foregroundStyle(.text.opacity(0.8))
                                        .padding(.leading, 12)
                                }
                            }
                        }
                    }
                }
                
            case .nesting:
                VStack(alignment: .leading, spacing: 12) {
                    makeExpandableText(birdDetail.nestingHabits  ?? "No additional information available")
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Eggs")
                            .font(.app(.Headline4))
                            .foregroundStyle(.text)
                            .padding(.top, 8)
                        makeTextContent(birdDetail.eggsDescription  ?? "No additional information available")
                    }
                }
                
            case .distribution:
                if !birdDetail.distributions.isEmpty {
                    ForEach(birdDetail.distributions.prefix(5), id: \.id) { dist in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(monthName(dist.month))
                                    .font(.app(.Sub1))
                                    .foregroundStyle(.text)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(dist.season.capitalized)
                                    . font(.app(. Micro1))
                                    .foregroundStyle(Color(hex: "#BCB22A"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .adaptiveGlassEffect(style:  .clear)
                            }
                            Text("\(dist.location.region ??  ""), \(dist.location.country)")
                                .font(.app(. Sub2))
                                .foregroundStyle(.text.opacity(0.8))
                            Text(dist.description  ?? "No additional information available")
                                .font(.app(.Sub2))
                                .foregroundStyle(.text.opacity(0.7))
                                .padding(.top, 2)
                        }
                        .padding(.vertical, 8)
                        if dist.id != birdDetail.distributions.prefix(5).last?.id {
                            Divider().background(. text.opacity(0.2))
                        }
                    }
                } else {
                    Text("No distribution data available")
                        .font(. app(.Sub1))
                        .foregroundStyle(.text.opacity(0.6))
                        .italic()
                }
                
            case .taxonomy:
                let tax = birdDetail.taxonomy
                VStack(alignment: .leading, spacing: 8) {
                    makeTaxonomyRow("Genus", tax.genus  ?? "No additional information available")
                    makeTaxonomyRow("Family", tax.family  ?? "No additional information available")
                    makeTaxonomyRow("Order", tax.order  ?? "No additional information available")
                    makeTaxonomyRow("Class", tax.`class`  ?? "No additional information available")
                    makeTaxonomyRow("Phylum", tax.phylum ??  "No additional information available")
                }
                
            case .conservation:
                let cons = birdDetail.conservationStatus
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(cons.fullName)
                            .font(. app(. Headline4))
                            .foregroundStyle(conservationColor(cons.severityLevel ??  0))
                        Spacer()
                        Text(cons.code)
                            .font(.app(. Micro1))
                            .foregroundStyle(.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            . adaptiveGlassEffect(style: .clear)
                    }
                    Text("Authority: \(cons.authority ??  "")")
                        .font(.app(.Sub2))
                        . foregroundStyle(.text.opacity(0.8))
                    makeTextContent(cons.description  ??  "No additional information available")
                }
                
            case .commonNames:
                ForEach(birdDetail.commonNames, id: \.id) { name in
                    HStack {
                        Text(name.name)
                            .font(.app(.Sub1))
                            .foregroundStyle(.text)
                        Spacer()
                        Text("\(name.region ?? "") (\(name.language))")
                            .font(.app(. Micro1))
                            .foregroundStyle(.text.opacity(0.7))
                    }
                    .padding(. vertical, 4)
                }
                
            case .coolFacts:
                let facts = birdDetail.coolFacts! . split(separator: "\n\n").map { String($0) }
                ForEach(Array(facts.enumerated()), id: \.offset) { index, fact in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.app(.Sub1))
                            . foregroundStyle(Color(hex: "#BCB22A"))
                            .fontWeight(.bold)
                        Text(fact)
                            .font(.app(. Sub1))
                            .foregroundStyle(.text)
                    }
                }
                
            case .size:
                let size = birdDetail.size
                VStack(alignment: .leading, spacing: 12) {
                    makeSizeRow("Length", min: Int(size.lengthCm.min ?? 0), max: Int(size.lengthCm.max ?? 0), unit: "cm")
                    makeSizeRow("Wingspan", min: Int(size.wingspanCm.min ?? 0), max: Int(size.wingspanCm.max ?? 0), unit: "cm")
                    makeSizeRow("Weight", min: Int(size.weightGrams.min ?? 0), max: Int(size.weightGrams.max ?? 0), unit: "g")
                    Text("Life Expectancy: ~\(birdDetail.lifeExpectancyYears ?? "") years")
                        .font(. app(.Sub1))
                        .foregroundStyle(.text)
                        .padding(.top, 8)
                }
            }
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func makeExpandableText(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .lineLimit(showFullDescription ? nil : 3)
                .font(.app(.Sub1))
                .foregroundStyle(. text)
                .multilineTextAlignment(.leading)
            if text.count > 150 {
                Button(showFullDescription ? "Less" : "Read more") {
                    withAnimation(.easeInOut) { showFullDescription.toggle() }
                }
                .font(.app(. Headline4))
                .foregroundStyle(Color(hex: "#BCBCBC"))
                .padding(.top, 4)
            }
        }
    }
    
    @ViewBuilder
    private func makeTextContent(_ text: String) -> some View {
        Text(text)
            .font(. app(.Sub1))
            .foregroundStyle(. text)
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
                .foregroundStyle(. text)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func makeSizeRow(_ label: String, min: Int, max: Int, unit: String) -> some View {
        HStack {
            Text(label)
                .font(.app(.Sub1))
                .foregroundStyle(.text)
            Spacer()
            Text("\(min) - \(max) \(unit)")
                .font(.app(.Sub1))
                .foregroundStyle(.text)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Helpers
    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(month: month))!
        return formatter.string(from: date)
    }
    
    private func conservationColor(_ severity: Int) -> Color {
        switch severity {
        case 1...2:  return .red
        case 3...4: return Color(hex: "#BCB22A")
        case 5...6: return . green
        default: return .text
        }
    }
}

// MARK: - BirdInfoType
enum BirdInfoType: String, CaseIterable {
    case commonNames = "Common Names"
    case size = "Size & Lifespan"
    case description = "Description"
    case habitat = "Habitat"
    case birdFoods = "Bird Foods"
    case behavior = "Behavior"
    case feeding = "Feeding"
    case nesting = "Nesting"
    case distribution = "Distribution"
    case taxonomy = "Taxonomy"
    case conservation = "Conservation"
    case coolFacts = "Cool Facts"
    
    var title: String { rawValue }
}

#Preview {
    ScrollView {
        BirdInfoItem(uploadResponse: .mock)
    }
    .background(Color(hex: "#5B765C"))
}
