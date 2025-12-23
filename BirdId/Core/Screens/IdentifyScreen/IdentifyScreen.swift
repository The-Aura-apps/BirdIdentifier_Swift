//
//  IdentifyScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 7/30/1404 AP.
//

import SwiftUI
import PhotosUI

struct IdentifyScreen: View {
    // MARK: - Properties
    @StateObject private var viewModel = IdentifyViewModel()
    @StateObject private var camera = CameraController()
    @StateObject private var gallery = PhotoPickerController()
    @StateObject private var audioPicker = AudioPickerController()
    @StateObject private var audio = AudioRecorderController()
    @EnvironmentObject private var coordinator: Coordinator
    
    @Binding var selectedTab: TabBarItem
    @Binding var currentMode: IdentificationMode
    
    @Namespace private var animation
    
    // MARK:  - Body
    var body: some View {
        ZStack {
            backgroundView
            mainContent
            
            if viewModel.showSearchResult {
                SearchResultScreen()
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }

            if viewModel.showCheckedView {
                CheckedView(checkedState: viewModel.checkedState ??  .failure)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .onChange(of: camera.capturedImage) { image in
            guard let image,
                  let data = image.jpegData(compressionQuality: 0.8) else { return }

            viewModel.uploadImage(data)
        }
        .setupLifecycle(
            viewModel: viewModel,
            coordinator: coordinator,
            camera: camera,
            audio: audio
        )
        .handleGallerySelection(gallery: gallery, viewModel: viewModel)
        .handleAudioPickerSelection(audioPicker: audioPicker, viewModel: viewModel) 
        .sheet(isPresented: $audioPicker.isPresented) { 
            AudioPicker(controller: audioPicker)
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - View Components
private extension IdentifyScreen {
    var backgroundView: some View {
        Group {
            if camera.isConfigured && currentMode == .camera {
                CameraLiveView(controller: camera)
            } else {
                Color(hex: "#5B765C")
            }
        }
        .ignoresSafeArea()
    }
    
    var mainContent: some View {
        VStack(spacing: 0) {
            headerSection
            
            currentScreenContent
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            BottomBarView(
                currentMode: $currentMode,
                gallerySelection: gallery,
                audioPicker: audioPicker,
                audio: audio,
                animation: animation,
                onCapturePhoto: handleCapturePhoto,
                onMicRecord: handleMicRecord,
                onGallery: handleGallery,
                onAudioPicker: handleAudioPicker
            )
            .frame(height: UIScreen.screenHeight / 5.325)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    
    var headerSection: some View {
        HStack {
            IdentifyBackButton(selectedTab: $selectedTab)
            Spacer()
            if currentMode == .camera {
                InfoCircleButton()
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, 24)
    }

    
    var bottomSection: some View {
        VStack {
            VStack {
                Spacer()
                currentScreenContent
                    .padding(.horizontal, 24)
            }
            
            BottomBarView(
                currentMode: $currentMode,
                gallerySelection: gallery,
                audioPicker: audioPicker,
                audio: audio,
                animation: animation,
                onCapturePhoto: handleCapturePhoto,
                onMicRecord: handleMicRecord,
                onGallery: handleGallery,
                onAudioPicker: handleAudioPicker
            )
            .frame(height: UIScreen.screenHeight / 5.325)
            .background(Color.clear)
        }
    }
    
    @ViewBuilder
    var currentScreenContent: some View {
        Group {
            switch currentMode {
            case .camera:
                CameraScreenContent()
            case .mic:
                MicScreenContent(audio: audio)
            case .gallery:
                CameraScreenContent()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: currentMode)
    }
}

// MARK: - Action Handlers
private extension IdentifyScreen {
    func handleCapturePhoto() {
        if currentMode != .camera {
            currentMode = .camera
        }
        camera.capturePhoto()
    }

    
    func handleMicRecord() {
        if audio.recording {
            audio.stopRecording()
            
            guard let fileURL = audio.recordedFileURL,
                  let data = try?  Data(contentsOf: fileURL) else {
                return
            }
        
            viewModel.uploadAudio(data)
        } else {
            audio.startRecording()
        }
    }
    
    func handleGallery() {

    }
    
    func handleAudioPicker() {
        audioPicker.presentAudioPicker()
    }
}

// MARK: - Screen Content Views
struct CameraScreenContent: View {
    var body: some View {
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
}

struct MicScreenContent: View {
    @ObservedObject var audio: AudioRecorderController
    
    var body: some View {
        VStack {
            Spacer()
            
            LottieView(
                animationName: "VoiceVisualization",
                animationSpeed: audio.recording ? 1.0 : 0,
                color: UIColor.white
            )
            .id(audio.recording)
            .foregroundStyle(.text)
            .frame(height: UIScreen.screenHeight / 2.13)
            . animation(.easeIn(duration: 0.3), value: audio.recording)
            
            recordingDuration
            recordingInstructions
        }
    }
    
    private var recordingDuration: some View {
        Text(formatTime(audio.recordingDuration))
            .font(.app(.Sub2))
            .foregroundStyle(.text)
            .padding(.vertical, 4)
            .padding(.horizontal, 16)
            .adaptiveGlassEffect(style: .clear, cornerRadius: 16)
    }
    
    private var recordingInstructions:  some View {
        Text(instructionText)
            .font(.app(.Sub2))
            .foregroundStyle(.text)
            .multilineTextAlignment(.center)
            .animation(.easeIn(duration: 0.3), value: audio.recording)
    }
    
    private var instructionText: String {
        if audio.recording {
            return audio.recordingDuration < 5
                ? "Pls record at least 5 seconds"
                : "Tap the button below to upload the recording"
        } else {
            return "Tap the button below to start Recording"
        }
    }
}

// MARK: - Bottom Bar View
struct BottomBarView:  View {
    @Binding var currentMode: IdentificationMode
    @ObservedObject var gallerySelection: PhotoPickerController
    @ObservedObject var audioPicker: AudioPickerController
    @ObservedObject var audio: AudioRecorderController
    
    let animation: Namespace.ID
    let onCapturePhoto: () -> Void
    let onMicRecord: () -> Void
    let onGallery: () -> Void
    let onAudioPicker: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .center) {
                leftButton
                Spacer()
                centerButton
                Spacer()
                toggleButton
            }
            .padding(.horizontal, 48)
            Spacer()
        }
    }
    
    @ViewBuilder
    private var leftButton: some View {
        if currentMode == .mic {
            audioPickerButton
        } else {
            galleryButton
        }
    }
    
    private var galleryButton: some View {
        PhotosPicker(selection: $gallerySelection.imageSelection) {
            Image(. galleryAdd)
                .frame(width: 24, height: 24)
                .padding(.all, 12)
                .adaptiveGlassEffect(style:  .clear, cornerRadius: 16)
        }
    }
    
    private var audioPickerButton: some View {
        Button(action: onAudioPicker) {
            Image(systemName: "folder.fill.badge.plus")
                .frame(width: 24, height:  24)
                .padding(. all, 12)
                .foregroundColor(.white)
                .adaptiveGlassEffect(style:  .clear, cornerRadius: 16)
        }
    }
    
    @ViewBuilder
    private var centerButton: some View {
        if currentMode == .camera || currentMode == .gallery {
            cameraButton
        } else if currentMode == .mic {
            micButton
        }
    }
    
    private var cameraButton: some View {
        Button(action: onCapturePhoto) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .overlay {
                    Image(.camera)
                        .frame(width: 32, height: 32)
                }
                .adaptiveGlassEffect(style: .clear, cornerRadius: 99)
                .frame(width: UIScreen.screenWidth / 5.46, height: UIScreen.screenHeight / 11.83)
        }
        .matchedGeometryEffect(id:  "camera", in: animation)
    }
    
    private var micButton: some View {
        Button(action: onMicRecord) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .overlay {
                    Image(audio.recording ? .record : .microphone)
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                . adaptiveGlassEffect(style: .clear, cornerRadius: 99)
                .frame(width: UIScreen.screenWidth / 5.46, height: UIScreen.screenHeight / 11.83)
        }
        .id(audio.recording)
        .matchedGeometryEffect(id: "micButton", in: animation)
    }
    
    @ViewBuilder
    private var toggleButton: some View {
        if currentMode == . camera || currentMode == .gallery {
            switchToMicButton
        } else if currentMode == .mic {
            switchToCameraButton
        }
    }
    
    private var switchToMicButton: some View {
        Button(action: { switchMode(to: .mic) }) {
            Image(. microphone)
                .frame(width: 24, height: 24)
                .padding(.all, 12)
                .adaptiveGlassEffect(style:  .clear, cornerRadius: 16)
        }
        .matchedGeometryEffect(id: "mic", in: animation)
    }
    
    private var switchToCameraButton: some View {
        Button(action: {
            print("🛑 stopRecording() called")
            audio.stopRecording()
            switchMode(to: .camera)
        }) {
            Image(.camera)
                .frame(width: 24, height: 24)
                .padding(.all, 12)
                .adaptiveGlassEffect(style: .clear, cornerRadius: 16)
        }
        .matchedGeometryEffect(id: "camera", in: animation)
    }
    
    private func switchMode(to mode: IdentificationMode) {
        withAnimation(. spring(response: 0.45, dampingFraction: 0.75)) {
            currentMode = mode
        }
    }
}

// MARK: - View Modifiers
private extension View {
    func setupLifecycle(
        viewModel: IdentifyViewModel,
        coordinator: Coordinator,
        camera: CameraController,
        audio: AudioRecorderController
    ) -> some View {
        self
            .onAppear {
                viewModel.setCoordinator(coordinator)
            }
            .onDisappear {
                if camera.isConfigured { camera.stop() }
                if audio.recording { audio.stopRecording() }
                viewModel.cleanup()
            }
    }
    
    func handleGallerySelection(
        gallery: PhotoPickerController,
        viewModel: IdentifyViewModel
    ) -> some View {
        self.onChange(of: gallery.selectedImage) { newImage in
            guard let image = newImage,
                  let data = image.jpegData(compressionQuality: 0.8) else {
                return
            }
            viewModel.uploadImage(data)
        }
    }
    
    func handleAudioPickerSelection(
        audioPicker: AudioPickerController,
        viewModel:  IdentifyViewModel
    ) -> some View {
        self.onChange(of: audioPicker.selectedAudioData) { newData in
            guard let data = newData else { return }
            viewModel.uploadAudio(data)
            audioPicker.resetSelection()
        }
    }
    
    func presentSearchResult(isPresented: Binding<Bool>) -> some View {
        self.fullScreenCover(isPresented:  isPresented) {
            SearchResultScreen()
        }
    }
    
    func presentCheckedView(
        isPresented: Binding<Bool>,
        checkedState: CheckedState?
    ) -> some View {
        self.fullScreenCover(isPresented: isPresented) {
            if let state = checkedState {
                CheckedView(checkedState: state)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    IdentifyScreen(
        selectedTab: .constant(.home),
        currentMode: .constant(.camera)
    )
    .environmentObject(Coordinator())
}
