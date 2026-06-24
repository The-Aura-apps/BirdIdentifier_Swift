//
//  Coordinator.swift
//  BirdId
//
//  Created by ali bakhsha on 7/20/1404 AP.
//

import Foundation
import SwiftUI
import Combine


enum Route: Hashable {
//    case IdentifyScreen
    case birdDetail(birdId: Int)
    case ResultScreen(uploadResponse: UploadResponse)
    case IdentifyScreen(currentMode: IdentificationMode)
    case HabitatScreen(habitatId: Int,title :String,description: String)
    case ArticleScreen(title :String)
    
    // Custom Hashable implementation since ObservationDetailResponse needs to be Hashable
    func hash(into hasher: inout Hasher) {
        switch self {
        case.birdDetail(let birdId):
            hasher.combine("birdDetail")
            hasher.combine(birdId)
        case .ResultScreen(let detail):
            hasher.combine("ResultScreen")
            hasher.combine(detail.bird.id)
        case .IdentifyScreen(let mode):
            hasher.combine("IdentifyScreen")
            hasher.combine(mode)
        case .HabitatScreen(let habitatId,let title,let description):
            hasher.combine("HabitatScreen")
            hasher.combine(title)
            hasher.combine(description)
            hasher.combine(habitatId)
        case .ArticleScreen(let title):
            hasher.combine("ArticleScreen")
            hasher.combine(title)
        }
    }
    
    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (.birdDetail(let lId), .birdDetail(let rId)):
            return lId == rId
        case (.ResultScreen(let lDetail), .ResultScreen(let rDetail)):
            return lDetail.bird.id == rDetail.bird.id
        case (.IdentifyScreen(let lMode), .IdentifyScreen(let rMode)):
            return lMode == rMode
        case (.HabitatScreen(let lId, let lTitle, let lDescription),
              .HabitatScreen(let rId, let rTitle, let rDescription)):
            return lId == rId && lTitle == rTitle && lDescription == rDescription
        case (.ArticleScreen(let lTitle), .ArticleScreen(let rTitle)):
            return lTitle == rTitle
        default:
            return false
        }
    }
}


class Coordinator: ObservableObject {
    @Published var path: [Route] = []
    @Published var identifyMode: IdentificationMode = .camera
    
    // Push a route with its model
    func push(_ route: Route) {
        path.append(route)
    }
    
    // Pop to root
    func popToRoot() {
        path.removeAll()
    }
    
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
        
    }
    // Pop to a specific route (matching by case, ignoring model data)
    func popTo(_ targetRoute: Route) {
        if let index = path.lastIndex(where: { type(of: $0) == type(of: targetRoute) }) {
            path = Array(path.prefix(index + 1))
        } else {
            print("Target route not found")
        }
    }
    
    // Build view with model
    @ViewBuilder
    func buildView(for route: Route) -> some View {
        switch route {
        case .birdDetail(let birdId):
            ResultScreen(birdId: birdId)
        case .ResultScreen(let uploadResponse):
                    ResultScreen(uploadResponse: uploadResponse)
                        .environmentObject(self)
        case .IdentifyScreen(let currentMode):
            IdentifyScreen(
                selectedTab: .constant(.identify),
                currentMode: Binding(
                    get: { self.identifyMode },
                    set: { self.identifyMode = $0 }
                ))
            .environmentObject(self)
        case .HabitatScreen(let habitatId,let habitatName,let description):
            HabitatScreen(habitatId: habitatId,title: habitatName,description: description)
                .environmentObject(self)
        case .ArticleScreen(let title):
            ArticleScreen(articleId: title)
                .environmentObject(self)
        }
    }
}
