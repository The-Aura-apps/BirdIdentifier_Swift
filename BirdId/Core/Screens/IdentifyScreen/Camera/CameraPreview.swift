//
//  CameraPreview.swift
//  BirdId
//
//  Created by ali bakhsha on 8/3/1404 AP.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    class CameraView: UIView {
        private var session: AVCaptureSession?

        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        private var previewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }

        func startSession() {
            let session = AVCaptureSession()
            session.sessionPreset = .photo

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device)
            else { return }

            if session.canAddInput(input) {
                session.addInput(input)
            }

            let output = AVCapturePhotoOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.session = session
            session.startRunning()
            self.session = session
        }

        func stopSession() {
            session?.stopRunning()
            session = nil
        }
    }

    func makeUIView(context: Context) -> CameraView {
        let view = CameraView()
        view.startSession()
        return view
    }

    func updateUIView(_ uiView: CameraView, context: Context) {}
}
