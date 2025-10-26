//
//  CameraController.swift
//  BirdId
//
//  Created by ali bakhsha on 8/3/1404 AP.
//

import Foundation
import AVFoundation
import UIKit
import Combine

final class CameraController: NSObject, ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    @Published var capturedImage: UIImage? {
        willSet { objectWillChange.send() }
    }

    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var deviceInput: AVCaptureDeviceInput?
    private var isConfigured = false

    override init() {
        super.init()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.configureSession()
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                self.deviceInput = input
            } else {
                print("⚠️ Cannot add camera input.")
            }

            if session.canAddOutput(output) {
                session.addOutput(output)
            } else {
                print("⚠️ Cannot add photo output.")
            }

            session.commitConfiguration()
            isConfigured = true

            start()
        } catch {
            print("⚠️ Camera configuration failed: \(error.localizedDescription)")
            session.commitConfiguration()
        }
    }

    func makePreviewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }

    func start() {
        guard isConfigured else {
            print("⚠️ Camera not configured yet.")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func capturePhoto() {
        guard session.isRunning else {
            print("⚠️ Capture called but session not running!")
            return
        }

        guard let connection = output.connection(with: .video), connection.isEnabled else {
            print("⚠️ No active video connection!")
            return
        }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            print("⚠️ Photo capture error: \(error)")
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            print("⚠️ Could not get photo data")
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = image
        }
    }
}
