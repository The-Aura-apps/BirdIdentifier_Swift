//
//  IdentifyScreenViewModel.swift
//  BirdId
//
//  Created by ali bakhsha on 7/30/1404 AP.
//

import SwiftUI
import Combine

final class IdentifyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var uploadResponse: UploadResponse?
    @Published var observationDetail: ObservationDetailResponse?
    @Published var showSearchResult = false
    @Published var showResult = false
    @Published var checkedState: CheckedState?
    @Published var showCheckedView = false
    
    // MARK: - Private Properties
    private var cancelBag = Set<AnyCancellable>()
    private let uploadRepo: UploadRepositoryProtocol
    private let observationRepo: ObservationRepositoryProtocol
    private weak var coordinator: Coordinator?
    private var pollingCancellable: AnyCancellable?
    
    private var deviceId: String {
        DeviceIDManager.shared.getDeviceUUID()
    }
    
    // MARK: - Constants
    private enum PollingConfig {
        static let maxAttempts = 120
        static let interval: TimeInterval = 2.0
        static let successDisplayDuration: TimeInterval = 3
        static let failureDisplayDuration: TimeInterval = 3
    }
    
    // MARK: - Initialization
    init(
        uploadRepo: UploadRepositoryProtocol = UploadRepository(),
        observationRepo: ObservationRepositoryProtocol = ObservationRepository()
    ) {
        self.uploadRepo = uploadRepo
        self.observationRepo = observationRepo
    }
    
    // MARK: - Public Methods
    func setCoordinator(_ coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
    func uploadImage(_ data: Data) {
        uploadMedia(data, type: .image)
    }
    
    func uploadAudio(_ data: Data) {
        uploadMedia(data, type: .audio)
    }
    
    func checkObservationStatus(id: String) {
        observationRepo.getObservationStatus(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: handleStatusCheckCompletion,
                receiveValue: handleStatusCheckValue
            )
            .store(in: &cancelBag)
    }
    
    func cleanup() {
        pollingCancellable?.cancel()
        pollingCancellable = nil
        cancelBag.removeAll()
    }
    
    // MARK: - Private Methods
    private func uploadMedia(_ data: Data, type: MediaType) {
        isLoading = true
        errorMessage = nil
        
        print("📤 Uploading \(type.rawValue) to server...")
        showSearchResult = true
        
        uploadRepo.uploadMedia(file: data, deviceId: deviceId, type: type.rawValue)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] in self?.handleUploadCompletion($0, type: type) },
                receiveValue: { [weak self] in self?.handleUploadSuccess($0) }
            )
            .store(in: &cancelBag)
    }
    
    private func handleUploadCompletion(_ completion: Subscribers.Completion<Error>, type: MediaType) {
        switch completion {
        case .finished:
            print("✅ \(type.displayName) upload finished")
        case .failure(let error):
            isLoading = false
            handleFailure(error: error)
            print("❌ \(type.displayName) upload failed: \(error.localizedDescription)")
        }
    }
    
    private func handleUploadSuccess(_ response: UploadResponse) {
        print("📥 Server response: \(response)")
        uploadResponse = response
        startPollingObservation(id: response.observation.id)
    }
    
    private func startPollingObservation(id: String) {
//        showSearchResult = true
        print("🔄 Starting to poll observation: \(id)")
        
        pollingCancellable = observationRepo.pollObservationUntilComplete(
            id: id,
            maxAttempts: PollingConfig.maxAttempts,
            interval: PollingConfig.interval
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: handlePollingCompletion,
            receiveValue: handlePollingValue
        )
    }
    
    private func handlePollingCompletion(_ completion: Subscribers.Completion<Error>) {
        isLoading = false
        
        switch completion {
        case .finished:
            print("✅ Polling completed successfully")
        case .failure(let error):
            print("❌ Polling failed: \(error.localizedDescription)")
            handleFailure(error: error)
        }
    }
    
    private func handlePollingValue(_ detail: ObservationDetailResponse) {
        print("📥 Observation status: \(detail.status.rawValue)")
        observationDetail = detail
        
        switch detail.status {
        case .completed:
            handleCompletedObservation(detail)
        case .processing:
            handleProcessingObservation(detail)
        case .failed:
            handleFailedObservation(detail)
        case .pending:
            print("⏳ Observation pending: \(detail)")
        }
    }
    
    private func handleCompletedObservation(_ detail: ObservationDetailResponse) {
        print("✅ Observation completed: \(detail)")
        
        // Cancel polling
        pollingCancellable?.cancel()
        pollingCancellable = nil
        
        // Hide search result and show success check
        showSearchResult = false
        checkedState = .success
        showCheckedView = true
        
        // After delay, navigate to result screen
        DispatchQueue.main.asyncAfter(deadline: .now() + PollingConfig.successDisplayDuration) { [weak self] in
            guard let self = self else { return }
            
            self.showCheckedView = false
            
            guard let coordinator = self.coordinator else {
                print("❌ Coordinator not set - using fallback navigation")
                self.showResult = true
                return
            }
            
            print("🚀 Pushing to ResultScreen via coordinator")
            coordinator.push(.ResultScreen(observationDetail: detail))
            print("📊 Coordinator path count: \(coordinator.path.count)")
        }
    }
    
    private func handleProcessingObservation(_ detail: ObservationDetailResponse) {
        print("⏳ Observation processing: \(detail)")
        showSearchResult = true
    }
    
    private func handleFailedObservation(_ detail: ObservationDetailResponse) {
        print("❌ Observation failed: \(detail)")
        
        // Cancel polling
        pollingCancellable?.cancel()
        pollingCancellable = nil
        
        let errorMsg = detail.errorMessage ?? "Processing failed"
        handleFailure(error: ObservationError.processingFailed(errorMsg))
    }
    
    private func handleFailure(error: Error) {
        // Hide search result and show failure check
        showSearchResult = false
        checkedState = .failure
        showCheckedView = true
        
        // After delay, go back
        DispatchQueue.main.asyncAfter(deadline: .now() + PollingConfig.failureDisplayDuration) { [weak self] in
            guard let self = self else { return }
            
            self.showCheckedView = false
            
            // Optionally show error message or just go back
            if let coordinator = self.coordinator {
                coordinator.pop()
            }
        }
    }
    
    private func handleStatusCheckCompletion(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            print("✅ Status check completed")
        case .failure(let error):
            print("❌ Status check failed: \(error.localizedDescription)")
        }
    }
    
    private func handleStatusCheckValue(_ detail: ObservationDetailResponse) {
        print("📥 Observation status: \(detail.status.rawValue)")
        observationDetail = detail
    }
}

// MARK: - Media Type
extension IdentifyViewModel {
    enum MediaType: String {
        case image
        case audio
        
        var displayName: String {
            switch self {
            case .image: return "Image"
            case .audio: return "Audio"
            }
        }
    }
}
