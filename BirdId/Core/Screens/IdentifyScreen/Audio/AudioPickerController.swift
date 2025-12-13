//
//  AudioPickerController. swift
//  BirdId
//
//  Created by ali bakhsha on 9/21/1404 AP.
//

import Foundation
import SwiftUI
import UIKit
import Combine
import UniformTypeIdentifiers

class AudioPickerController: NSObject, ObservableObject {
    @Published var selectedAudioURL: URL?
    @Published var selectedAudioData: Data?
    @Published var isPresented = false
    
    func presentAudioPicker() {
        isPresented = true
    }
    
    func resetSelection() {
        selectedAudioURL = nil
        selectedAudioData = nil
    }
}

// MARK: - UIViewControllerRepresentable
struct AudioPicker: UIViewControllerRepresentable {
    @ObservedObject var controller: AudioPickerController
    
    func makeUIViewController(context:  Context) -> UIDocumentPickerViewController {
        let audioTypes: [UTType] = [
            .audio,
            .mp3,
            .mpeg4Audio,
            .wav,
            .m4a
        ].compactMap { $0 }
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: audioTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator:  NSObject, UIDocumentPickerDelegate {
        let parent: AudioPicker
        
        init(_ parent: AudioPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            guard url.startAccessingSecurityScopedResource() else {
                print("❌ Cannot access file")
                return
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            do {
                let data = try Data(contentsOf: url)
                
                DispatchQueue.main.async {
                    self.parent.controller.selectedAudioURL = url
                    self.parent.controller.selectedAudioData = data
                    self.parent.controller.isPresented = false
                    
                    print("✅ Audio file selected: \(url.lastPathComponent)")
                    print("✅ File size: \(data.count) bytes")
                }
            } catch {
                print("❌ Error reading audio file: \(error)")
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            DispatchQueue.main.async {
                self.parent.controller.isPresented = false
            }
        }
    }
}

// MARK: - UTType Extensions for older audio formats
extension UTType {
    static var m4a: UTType?  {
        UTType(filenameExtension:  "m4a")
    }
    
    static var wav: UTType? {
        UTType(filenameExtension:  "wav")
    }
}
