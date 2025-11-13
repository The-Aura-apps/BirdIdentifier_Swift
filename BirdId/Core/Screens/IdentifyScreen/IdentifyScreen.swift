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
            if camera.isConfigured && currentMode == .camera{
                CameraLiveView(controller: camera)
                    .ignoresSafeArea()
            } else {
                Color(hex: "#5B765C")
                    .ignoresSafeArea()
            }
            
            VStack {
                // MARK: Header & Camera Section
                ZStack {
                    VStack{
                        HStack {
                            IdentifyBackButton(selectedTab: $selectedTab)
                            Spacer()
                            InfoCircleButton()
                        }
                        .padding(.top, 48)
                        .padding(.horizontal,24)
                        Spacer()
                    }
                    
                    // MARK: Bottom Bar
                    VStack {
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
                                } else {
                                    currentMode = .camera
                                }
                            },
                            onMicRecord: {
                                if audio.recording {
                                    print("🛑 stopRecording() called")
                                    audio.stopRecording()
                                } else {
                                    print("🎙 startRecording() called")
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
            
            .padding(.top)
            .ignoresSafeArea()
        }
        .onDisappear {
            if camera.isConfigured { camera.stop() }
            if audio.recording { audio.stopRecording() }
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
                Spacer()
                Text("Identify a bird via photo")
                    .font(.app(.Sub2))
                    .foregroundStyle(.text)
            }
    }
    private func micScreen() -> some View {
        VStack {
            Spacer()
            LottieView(animationName: "VoiceVisualization",animationSpeed: audio.recording ? 1.0 : 0, color: UIColor.white)
                .id(audio.recording)
                .foregroundStyle(.text)
                .frame(height: UIScreen.screenHeight / 2.13)
                .animation(.easeIn(duration: 0.3), value: audio.recording)
            Text(formatTime(audio.recordingDuration))
                .font(.app(.Sub2))
                .foregroundStyle(.text)
                .padding(.vertical,4)
                .padding(.horizontal,16)
                .adaptiveGlassEffect(style: .clear, cornerRadius: 16)
            
            Text(audio.recording ?  audio.recordingDuration < 5 ? "Pls record at least 5 seconds" : "Tap the button below to upload the recording" : "Tap the button below to start Recording")
                .font(.app(.Sub2))
                .foregroundStyle(.text)
                .multilineTextAlignment(.center)
                .animation(.easeIn(duration: 0.3), value: audio.recording)
            
//            if let fileURL = audio.recordedFileURL, !audio.recording {
//                VStack {
//                    Text("Last Recording:")
//                        .font(.app(.Sub2))
//                        .foregroundStyle(.text)
//                    
//                    HStack {
//                        Button {
//                            if audio.playing {
//                                audio.stopPlayback()
//                            } else {
//                                audio.playRecording()
//                            }
//                        } label: {
//                            Image(systemName: audio.playing ? "stop.circle.fill" : "play.circle.fill")
//                                .resizable()
//                                .frame(width: 50, height: 50)
//                                .foregroundColor(audio.playing ? .red : .green)
//                        }
//                        
//                        Text(audio.playing ? "Playing..." : "Tap to play")
//                            .font(.app(.Sub2))
//                            .foregroundStyle(.text)
//                    }
//                }
//                .padding()
//                .adaptiveGlassEffect(style: .clear, cornerRadius: 16)
//                .transition(.opacity)
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
                } else if currentMode == .mic {
                    Button(action: onMicRecord) {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 72, height: 72)
                            .overlay {
                                Image(audio.recording ? .record : .microphone)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                            }
                            .adaptiveGlassEffect(style: .clear, cornerRadius: 99)
                    }
                    .id(audio.recording)
                    .matchedGeometryEffect(id: "micButton", in: animation)
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
                            print("🛑 stopRecording() called")
                            audio.stopRecording()
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
