//
//  CameraLiveView.swift
//  BirdId
//
//  Created by ali bakhsha on 8/3/1404 AP.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraLiveView: UIViewRepresentable {
    @ObservedObject var controller: CameraController

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        // ساخت preview layer و اضافه کردن به view
        let previewLayer = controller.makePreviewLayer()
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // ذخیره previewLayer در coordinator برای updateUIView
        context.coordinator.previewLayer = previewLayer
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // سینک کردن اندازه preview layer با UIView
        DispatchQueue.main.async {
            context.coordinator.previewLayer?.frame = uiView.bounds
        }
        
        // نمایش تصویر گرفته شده روی preview
        if let image = controller.capturedImage {
            let imageView: UIImageView
            if let existing = uiView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                imageView = existing
            } else {
                imageView = UIImageView(frame: uiView.bounds)
                imageView.contentMode = .scaleAspectFill
                imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                uiView.addSubview(imageView)
            }
            imageView.image = image
        }
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
