//
//  ArticleScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/30/1404 AP.
//


import SwiftUI
import Kingfisher

struct ArticleScreen: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var tabManager: TabManager
    @StateObject private var viewModel = ArticleViewModel()
    @State private var showFullDescription: Bool = false
    
    let articleId: String
    
    var body: some View {
        ZStack{
            Image(.bgImg)
                .resizable()
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if let article = viewModel.getArticle(by: articleId) {
                VStack{
                    makeHeaderImageSection(article: article)
                        .padding(.bottom,24)
                        
                    content(article: article)
                }
                .ignoresSafeArea(edges: .top)
            } else if let error = viewModel.errorMessage {
                VStack {
                    Text("Error loading article")
                        .font(.app(.Headline3))
                        .foregroundStyle(.text)
                    Text(error)
                        .font(.app(.Sub2))
                        .foregroundStyle(.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
        }
        .overlay (alignment: .bottom) {
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $tabManager.selectedTab)
                    .padding(.bottom, 24)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            tabManager.selectedTab = .home
            if viewModel.articles.isEmpty {
                viewModel.fetchArticles()
            }
        }
    }
}

extension ArticleScreen {
    func makeHeaderImageSection(article: Article) -> some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(URL(string: article.photoUrl))
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight / 2.42)
                .clipped()
                .cornerRadius(24)
                .ignoresSafeArea(edges: .top)
            
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight / 2.42)
            .cornerRadius(24)
            .ignoresSafeArea(edges: .top)
            
            VStack(alignment: .leading, spacing: 8) {
                BackButtonView()
                    .padding(.top, 24)
                
                Spacer()
                
                Text(article.title)
                    .font(.app(.Headline1))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                
                HStack(spacing: 6) {
                    Image(.clock)
                    Text(article.readingTime)
                    Text("•")
                    Text(article.formattedDate)
                }
                .font(.app(.Micro1))
                .foregroundStyle(.white.opacity(0.85))
            }
            .padding(24)
            .frame(height: UIScreen.screenHeight / 2.42)
        }
    }

    
    func content(article: Article) -> some View {
        ScrollView(showsIndicators: false) {
            VStack{
                HStack{
                    Text("Content")
                        .font(.app(.Headline4))
                        .foregroundStyle(.text)
                    
                    Spacer()
                }
                .padding(.horizontal,24)
                .padding(.bottom,24)
                
                VStack (alignment: .leading,spacing: 0){
                    Text(article.content)
                        .lineLimit(showFullDescription ? nil : 5)
                        .font(.app(.Sub1))
                        .foregroundStyle(.text)
                        .multilineTextAlignment(.leading)
                    
                    if article.content.count > 300 {
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
                .padding(.horizontal,24)
                .padding(.bottom, UIScreen.screenHeight / 13.3)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    ArticleScreen(articleId: "d6595e4b-a9bd-4e2a-828c-c8896c6f51ba")
        .environmentObject(Coordinator())
        .environmentObject(TabManager())
}
