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
    case ResultScreen(birdName: String)
    case IdentifyScreen(currentMode: IdentificationMode)
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
            ////        case .IdentifyScreen:
            ////            IdentifyScreen(selectedTab: .constant(.identify), coordinator: self)
            //        }
        case .ResultScreen(let birdName):
            ResultScreen()
            .environmentObject(self)
        case .IdentifyScreen(let currentMode):
            IdentifyScreen(
                selectedTab: .constant(.identify),
                currentMode: Binding(
                    get: { self.identifyMode },
                    set: { self.identifyMode = $0 }
                ))
            .environmentObject(self)
        }
    }
}
