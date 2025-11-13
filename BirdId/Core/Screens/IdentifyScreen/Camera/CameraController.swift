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
    @Published var capturedImage: UIImage?
    @Published var isConfigured = false
    @Published var error: CameraError?
    
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    enum CameraError: Error, LocalizedError {
        case unauthorized
        case configurationFailed
        case inputFailed
        case outputFailed
        
        var errorDescription: String? {
            switch self {
            case .unauthorized: return "Camera access is required"
            case .configurationFailed: return "Camera configuration failed"
            case .inputFailed: return "Could not setup camera input"
            case .outputFailed: return "Could not setup camera output"
            }
        }
    }
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.error = .unauthorized
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                self.error = .unauthorized
            }
        }
    }
    
    private func setupCamera() {
        sessionQueue.async {
            self.session.beginConfiguration()
            
            // Setup session
            self.session.sessionPreset = .photo
            
            // Setup input
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                DispatchQueue.main.async {
                    self.error = .inputFailed
                }
                self.session.commitConfiguration()
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                } else {
                    DispatchQueue.main.async {
                        self.error = .inputFailed
                    }
                    self.session.commitConfiguration()
                    return
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = .inputFailed
                }
                self.session.commitConfiguration()
                return
            }
            
            // Setup output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            } else {
                DispatchQueue.main.async {
                    self.error = .outputFailed
                }
                self.session.commitConfiguration()
                return
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.isConfigured = true
                self.start()
            }
        }
    }
    
    func start() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
                print("✅ Camera session started")
            }
        }
    }
    
    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
                print("🛑 Camera session stopped")
            }
        }
    }
    
    func capturePhoto() {
        sessionQueue.async {
            guard self.session.isRunning else {
                print("⚠️ Session is not running")
                return
            }
            
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .auto
            
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func switchCamera() {
        sessionQueue.async {
            guard let currentInput = self.session.inputs.first as? AVCaptureDeviceInput else { return }
            
            self.session.beginConfiguration()
            self.session.removeInput(currentInput)
            
            let newCameraDevice = currentInput.device.position == .back ?
                AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) :
                AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            
            guard let newDevice = newCameraDevice else { return }
            
            do {
                let newVideoInput = try AVCaptureDeviceInput(device: newDevice)
                if self.session.canAddInput(newVideoInput) {
                    self.session.addInput(newVideoInput)
                }
            } catch {
                print("Error switching camera: \(error)")
            }
            
            self.session.commitConfiguration()
        }
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ Photo capture error: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("❌ Could not process photo data")
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
            print("✅ Photo captured successfully")
        }
    }
}
