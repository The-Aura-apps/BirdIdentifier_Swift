//
//  IdentifyScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 7/30/1404 AP.
//

import SwiftUI
import PhotosUI


enum IdentificationMode: CaseIterable {
    case camera
    case mic
    case gallery
    
    var title: String {
        switch self {
        case .camera: return "Identify a bird via photo"
        case .mic: return "Identify a bird via sound"
        case .gallery: return "Identify a bird from gallery"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        default: return Color(hex: "#5B765C")
        }
    }
    
    var centerButtonIcon: Image {
        switch self {
        case .camera: return Image(.camera)
        case .mic: return Image(.microphone)
        case .gallery: return Image(.galleryAdd)
        }
    }
    
    var centerButtonAction: String {
        switch self {
        case .camera: return "capture"
        case .mic: return "record"
        case .gallery: return "select"
        }
    }
}

struct IdentifyScreen: View {
    @StateObject private var camera = CameraController()
    @StateObject private var gallery = PhotoPickerController()
    @Namespace private var animation
    @State private var currentMode: IdentificationMode = .camera
    
    var body: some View {
        ZStack {
            Image(.bgImg).resizable().ignoresSafeArea()
            
            VStack {
                // MARK: Header & Camera Section
                currentScreenContent()
                .frame(height: UIScreen.screenHeight / 1.25)
                .padding(.horizontal, 24)
                .background(Color(hex: "#5B765C"))
                
                
                // MARK: Bottom Bar
                BottomBarView(
                    currentMode: $currentMode,
                    gallerySelection: gallery,
                    animation: animation,
                    onCapturePhoto: {
                        if (currentMode == .camera){
                            camera.capturePhoto()
                        }else {
                            currentMode = .camera
                        }
                    },
                    onMicRecord: {
                        // mic recording logic
                    },
                    onGallery: {
                        // gallery selection logic
                    }
                )
                .frame(height: UIScreen.screenHeight / 5.325)
                .background(Color.clear)
            }
            .ignoresSafeArea()
        }
        .onDisappear {
            camera.stop()
        }
    }
    
}

extension IdentifyScreen {
    @ViewBuilder
    private func currentScreenContent() -> some View {
        Group{
            switch currentMode {
            case .camera:
                cameraScreen()
            case .mic:
                micScreen()
            default: cameraScreen()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: currentMode)
    }
    
    private func cameraScreen() -> some View {
        VStack {
            HStack {
                BackButtonView()
                Spacer()
                InfoCircleButton()
            }
            .padding(.top, 48)
            
            Spacer()
            Image(.cameraIdentify)
                .frame(height: UIScreen.screenHeight / 2.13)
                .padding(.horizontal)
            
            Spacer()
            Text("Identify a bird via photo")
                .font(.app(.Sub2))
                .foregroundStyle(.text)
            Spacer()
        }
    }
    private func micScreen() -> some View {
        VStack {
            HStack {
                BackButtonView()
                Spacer()
                InfoCircleButton()
            }
            .padding(.top, 48)
            Spacer()
            
            
            Text("00.00.0")
                .font(.app(.Sub2))
                .foregroundStyle(.text)
                .padding(.vertical,4)
                .padding(.horizontal,16)
                .adaptiveGlassEffect(style: .clear, cornerRadius: 16)
            
            Text("Tap the button below to start\n Recording")
                .font(.app(.Sub2))
                .foregroundStyle(.text)
                .multilineTextAlignment(.center)
                .padding(.vertical,24)
        }
    }
}


struct BottomBarView: View {
    @Binding var currentMode: IdentificationMode
    @ObservedObject var gallerySelection: PhotoPickerController
    let animation: Namespace.ID
    let onCapturePhoto: () -> Void
    let onMicRecord: () -> Void
    let onGallery: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .center) {
                PhotosPicker(selection: $gallerySelection.imageSelection) {
                        Image(.galleryAdd)
                            .frame(width: 24, height: 24)
                            .padding(.all, 12)
                            .adaptiveGlassEffect(style: .clear, cornerRadius: 16)
                }
                
                Spacer()
                
                // CENTER BUTTONS (camera or mic)
                if currentMode == .camera ||  currentMode == .gallery{
                    // Camera in center
                    Button(action: onCapturePhoto) {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 72, height: 72)
                            .overlay {
                                Image(.camera)
                                    .frame(width: 32, height: 32)
                            }
                            .adaptiveGlassEffect(style: .clear, cornerRadius: 99)
                    }
                    .matchedGeometryEffect(id: "camera", in: animation)
                } else if currentMode == .mic ||  currentMode == .gallery{
                    // Microphone in center
                    Button(action: onMicRecord) {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 72, height: 72)
                            .overlay {
                                Image(.microphone)
                                    .frame(width: 32, height: 32)
                            }
                            .adaptiveGlassEffect(style: .clear, cornerRadius: 99)
                    }
                    .matchedGeometryEffect(id: "mic", in: animation)
                }
                
                Spacer()
                
                if currentMode == .camera ||  currentMode == .gallery{
                    Button(action: {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                            currentMode = .mic
                        }
                    }) {
                        Image(.microphone)
                            .frame(width: 24, height: 24)
                            .padding(.all, 12)
                            .adaptiveGlassEffect(style: .clear, cornerRadius: 16)
                    }
                    .matchedGeometryEffect(id: "mic", in: animation)
                } else if currentMode == .mic ||  currentMode == .gallery{
                    Button(action: {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                            currentMode = .camera
                        }
                    }) {
                        Image(.camera)
                            .frame(width: 24, height: 24)
                            .padding(.all, 12)
                            .adaptiveGlassEffect(style: .clear, cornerRadius: 16)
                    }
                    .matchedGeometryEffect(id: "camera", in: animation)
                }
            }
            .padding(.horizontal, 48)
            Spacer()
        }
    }
}

#Preview {
    IdentifyScreen()
}
