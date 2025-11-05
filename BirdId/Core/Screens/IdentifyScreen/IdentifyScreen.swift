//
//  IdentifyScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 7/30/1404 AP.
//

import SwiftUI
import PhotosUI

struct IdentifyScreen: View {
    @Binding var selectedTab: TabBarItem
    @StateObject private var camera = CameraController()
    @StateObject private var gallery = PhotoPickerController()
    @StateObject private var audio = AudioRecorderController()
    @Namespace private var animation
    @State private var currentMode: IdentificationMode = .camera
    
    var body: some View {
        ZStack {
            Color(hex: "#5B765C")
                .ignoresSafeArea()
            
            VStack {
                // MARK: Header & Camera Section
                ZStack {
                    VStack{
                        HStack {
                            IdentifyBackButton(selectedTab: $selectedTab)
//                            Button(action: {
//                                selectedTab = .home
//                            }, label: {
//                                BackButtonView()
//                            })
                            Spacer()
                            InfoCircleButton()
                        }
                        .padding(.top, 48)
                        .padding(.horizontal,24)
                        Spacer()
                    }
                    
                    
                    // MARK: Bottom Bar
                    VStack {
                        Spacer()
                        if camera.isConfigured {
                            CameraLiveView(controller: camera)
                                .ignoresSafeArea()
                        }
                            
                            if let captured = camera.capturedImage {
                                Image(uiImage: captured)
                                    .resizable()
                                    .scaledToFit()
                                    .ignoresSafeArea()
                            }
                            
                        VStack {
                            Spacer()
                            currentScreenContent()
                                .padding(.horizontal, 24)
                        }
                        BottomBarView(
                            currentMode: $currentMode,
                            gallerySelection: gallery,
                            audio: audio,
                            animation: animation,
                            onCapturePhoto: {
                                if (currentMode == .camera){
                                    camera.capturePhoto()
                                }else {
                                    currentMode = .camera
                                }
                            },
                            onMicRecord: {
                                if audio.recording {
                                    audio.stopRecording()
                                } else {
                                    audio.startRecording()
                                }
                            },
                            onGallery: {
                                // gallery selection logic
                            }
                        )
                        .frame(height: UIScreen.screenHeight / 5.325)
                        .background(Color.clear)
                    }
                }
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
                Spacer()
                Image(.cameraIdentify)
                    .frame(height: UIScreen.screenHeight / 2.13)
//                    .padding()
                
                Spacer()
                Text("Identify a bird via photo")
                    .font(.app(.Sub2))
                    .foregroundStyle(.text)
            }
    }
    private func micScreen() -> some View {
        VStack {
            Spacer()
            LottieView(animationName: "VoiceVisualization",color: UIColor.white)
                .foregroundStyle(.text)
                .frame(height: UIScreen.screenHeight / 2.13)
//            Spacer()
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
//                .padding(.vertical,24)
            
//            if let fileURL = audio.recordedFileURL {
//                VStack(spacing: 12) {
//                    Text("🎙 Last Recording:")
//                        .font(.app(.Sub2))
//                        .foregroundStyle(.text)
//                    
//                    Text(fileURL.lastPathComponent)
//                        .font(.app(.Sub2))
//                        .foregroundStyle(.gray)
//                    
//                    HStack(spacing: 24) {
//                        Button {
//                            if audio.playing {
//                                audio.stopPlayback()
//                            } else {
//                                audio.playRecording()
//                            }
//                        } label: {
//                            Image(systemName: audio.playing ? "stop.circle.fill" : "play.circle.fill")
//                                .resizable()
//                                .frame(width: 48, height: 48)
//                                .foregroundStyle(audio.playing ? .red : .green)
//                        }
//                    }
//                    .padding(.top, 8)
//                }
//                .padding()
//                .adaptiveGlassEffect(style: .clear, cornerRadius: 16)
//            }

        }
    }
}


struct BottomBarView: View {
    @Binding var currentMode: IdentificationMode
    @ObservedObject var gallerySelection: PhotoPickerController
    @ObservedObject var audio: AudioRecorderController
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
                                Image(audio.recording ? .record : .microphone)
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
    IdentifyScreen(selectedTab: .constant(.home))
}
