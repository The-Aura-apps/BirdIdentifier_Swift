//
//  CameraLiveView.swift
//  BirdId
//
//  Created by ali bakhsha on 8/3/1404 AP.
//

import Foundation
import SwiftUI

struct CameraLiveView: UIViewRepresentable {
    @ObservedObject var controller: CameraController

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let preview = controller.makePreviewLayer()
        preview.frame = UIScreen.main.bounds
        view.layer.addSublayer(preview)
        controller.start()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
