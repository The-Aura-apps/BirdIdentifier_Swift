//
//  CameraLiveView.swift
//  BirdId
//
//  Created by ali bakhsha on 8/3/1404 AP.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraLiveView: UIViewControllerRepresentable {
    @ObservedObject var controller: CameraController
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.controller = controller
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Handle updates if needed
    }
}

class CameraViewController: UIViewController {
    var controller: CameraController!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreviewLayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start camera when view appears
        if controller.isConfigured {
            controller.start()
        }
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: controller.session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        previewLayer.connection?.videoOrientation = .portrait
        
        view.layer.addSublayer(previewLayer)
    }
}
