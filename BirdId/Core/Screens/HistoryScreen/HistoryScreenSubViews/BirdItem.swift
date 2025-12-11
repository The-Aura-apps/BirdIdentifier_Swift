//
//  HistoryItem.swift
//  BirdId
//
//  Created by ali bakhsha on 8/20/1404 AP.
//

import SwiftUI

struct HistoryItem: View {
    @EnvironmentObject var coordinator: Coordinator
    
    // دو ستونه، هر کارت تقریباً نصف صفحه منهای فاصله
    private let columns = [
        GridItem(.fixed(UIScreen.screenWidth / 2 - 24), spacing: 16),
        GridItem(.fixed(UIScreen.screenWidth / 2 - 24), spacing: 16)
    ]
    
    // ۱۱ تا داده mock ثابت (از مدل جدید)
    private let mockBirds: [UploadResponse] = [
        .mock,                    // Canada Goose (همون mock اصلی)
        .mock, .mock, .mock, .mock,
        .mock, .mock, .mock, .mock,
        .mock, .mock              // فعلاً تکراری — بعداً می‌تونی متنوع کنی
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(mockBirds, id: \.observation.id) { bird in
                    Button {
                        // حالا درست push می‌کنه با birdDetail
                        coordinator.push(.ResultScreen(uploadResponse:  bird))
                    } label: {
                        HistoryCard(bird: bird.bird)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
}

// MARK: - کارت جدا شده برای تمیزی و خوانایی
struct HistoryCard: View {
    let bird: BirdDetailResponse
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // تصویر پس‌زمینه (فعلاً ثابت — بعداً می‌تونی از bird.media.first استفاده کنی)
            Image(.recordPoster)
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.screenHeight / 6.08)
                .clipped()
                .cornerRadius(28)
            
            // گرادیان تیره برای خوانایی متن
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(28)
            
            // اطلاعات پرنده
            VStack(alignment: .leading, spacing: 4) {
                // اسم رایج (اولین نام انگلیسی)
                if let englishName = bird.commonNames.first(where: { $0.language == "en" })?.name {
                    Text(englishName)
                        .font(.app(.Sub1))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                } else {
                    Text("Unknown Bird")
                        .font(.app(.Sub1))
                        .foregroundStyle(.white)
                }
                
                // نام علمی
                Text(bird.scientificName)
                    .font(.app(.Micro1))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.screenHeight / 6.08)
    }
}

#Preview {
    HistoryItem()
        .environmentObject(Coordinator())
        .background(Color.black)
}
