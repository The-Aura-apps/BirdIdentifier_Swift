//
//  AudioRecorderController.swift
//  BirdId
//
//  Created by ali bakhsha on 8/8/1404 AP.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioRecorderController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
//    let objectWillChange = PassthroughSubject<AudioRecorderController, Never>()
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var recordingTimer: Timer?
    
    @Published var recording = false {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var playing = false {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var recordedFileURL: URL? {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var recordingDuration: TimeInterval = 0 {
        didSet {
            objectWillChange.send()
        }
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session: \(error)")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = "record_\(formatter.string(from: Date())).m4a"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.record()
//            recording = true
//            recordedFileURL = fileURL
            
            recordingDuration = 0
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                DispatchQueue.main.async {
                    self.recordingDuration += 0.1
                }
            }
            
            DispatchQueue.main.async {
                self.recording = true
                self.recordedFileURL = fileURL
            }
        } catch {
            print("Couldn't start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingDuration = 0
        
        DispatchQueue.main.async {
            self.recording = false
        }
    }
    
    func playRecording() {
        guard let fileURL = recordedFileURL else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.play()
            
            DispatchQueue.main.async {
                self.playing = true
            }
            
            audioPlayer?.delegate = self
        } catch {
            print("Playback failed: \(error)")
        }
        
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        
        DispatchQueue.main.async {
            self.playing = false
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.playing = false
        }
    }
}


func formatTime(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    let milliseconds = Int((time - Double(Int(time))) * 10)
    return String(format: "%02d.%02d.%d", minutes, seconds, milliseconds)
}
