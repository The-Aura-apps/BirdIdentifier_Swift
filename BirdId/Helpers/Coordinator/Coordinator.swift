//
//  Coordinator.swift
//  BirdId
//
//  Created by ali bakhsha on 7/20/1404 AP.
//

//import Foundation
//import SwiftUI
//
//
//enum Route: Hashable {
//    case SinglefolderScreen(String)
//    case TranscriptionScreen(String)
//}
//
//
//class Coordinator: ObservableObject {
//    @Published var path: [Route] = []
//    
//    // Push a route with its model
//    func push(_ route: Route) {
//        path.append(route)
//    }
//    
//    // Pop to root
//    func popToRoot() {
//        path.removeAll()
//    }
//    
//    
//    func pop() {
//        if !path.isEmpty {
//            path.removeLast()
//        }
//        
//    }
//    // Pop to a specific route (matching by case, ignoring model data)
//    func popTo(_ targetRoute: Route) {
//        if let index = path.lastIndex(where: { type(of: $0) == type(of: targetRoute) }) {
//            path = Array(path.prefix(index + 1))
//        } else {
//            print("Target route not found")
//        }
//    }
//    
//    // Build view with model
//    @ViewBuilder
//    func buildView(for route: Route) -> some View {
//        switch route {
//        case .SinglefolderScreen(let folderId) :
//            SingleFolderScreen(coordinator: self, folderId: folderId)
//        case .TranscriptionScreen(let transcriptionId):
//            TranscribeScreen(coordinator: self, transcriptionId: transcriptionId)
//        }
//    }
//}
