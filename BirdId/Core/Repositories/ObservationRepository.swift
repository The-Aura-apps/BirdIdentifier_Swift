//
//  ObservationRepository.swift
//  BirdId
//
//  Created by ali bakhsha on 9/3/1404 AP.
//

import Foundation
import Combine
import Alamofire

protocol ObservationRepositoryProtocol {
    func getObservationStatus(id: String) -> AnyPublisher<ObservationDetailResponse, Error>
    func pollObservationUntilComplete(id: String, maxAttempts: Int, interval: TimeInterval) -> AnyPublisher<ObservationDetailResponse, Error>
}

class ObservationRepository: ObservationRepositoryProtocol {
    
    private let api: ApiServiceProtocol
    
    init(api: ApiServiceProtocol = ApiService()) {
        self.api = api
    }
    
    // MARK: - Get Single Observation Status
    func getObservationStatus(id: String) -> AnyPublisher<ObservationDetailResponse, Error> {
        let url = "\(Constants.Urls.observations)\(id)"
        
        print("🌐 API Call - GET Observation Status")
        print("📡 URL: \(url)")
        print("🆔 Observation ID: \(id)")
        print("⏰ Timestamp: \(Date())")
        
        return api.request(
            url,
            method: .get,
            body: nil,
            headers: nil,
            expecting: ObservationDetailResponse.self
        )
        .handleEvents(
            receiveSubscription: { _ in
                print("🔗 Subscription started for observation \(id)")
            },
            receiveOutput: { response in
                print("✅ API Response Received:")
                print("   Status: \(response.status.rawValue)")
                print("   Bird ID: \(response.birdId ?? -1)")
                print("   Confidence: \(response.confidence ?? "N/A")")
                print("   Error: \(response.errorMessage ?? "None")")
            },
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("🏁 API Call completed successfully")
                case .failure(let error):
                    print("❌ API Call failed: \(error.localizedDescription)")
                }
            },
            receiveCancel: {
                print("🚫 API Call cancelled")
            }
        )
        .eraseToAnyPublisher()
    }
    
    // MARK: - Poll Until Complete
    /// Polls the observation status until it's completed or max attempts reached
    /// - Parameters:
    ///   - id: Observation ID
    ///   - maxAttempts: Maximum number of polling attempts (default: 60)
    ///   - interval: Time interval between polls in seconds (default: 2.0)
    func pollObservationUntilComplete(
        id: String,
        maxAttempts: Int = 120,
        interval: TimeInterval = 2.0
    ) -> AnyPublisher<ObservationDetailResponse, Error> {

        var attempts = 0

        return Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .prefix(while: { _ in
                attempts += 1
                print("Poll attempt \(attempts)/\(maxAttempts) for \(id)")
                return attempts <= maxAttempts
            })
            .flatMap { _ -> AnyPublisher<ObservationDetailResponse, Error> in
                return self.getObservationStatus(id: id)
                    .timeout(.seconds(12), scheduler: DispatchQueue.global())
                    .eraseToAnyPublisher()
            }
            .first(where: { detail in
                return detail.status == .completed || detail.status == .failed
            })
            .tryMap { detail -> ObservationDetailResponse in
                if detail.status == .failed {
                    if let errorMsg = detail.errorMessage, !errorMsg.isEmpty {
                        throw ObservationError.processingFailed(errorMsg)
                    } else {
                        throw ObservationError.processingFailed("Identification failed")
                    }
                }
                if detail.status == .completed {
                    return detail
                }
                throw ObservationError.timeout
            }
            .eraseToAnyPublisher()
    }

}

// MARK: - Custom Errors
enum ObservationError: LocalizedError {
    case timeout
    case stillProcessing
    case processingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .timeout:
            return "The bird identification took too long. Please try again."
        case .stillProcessing:
            return "Observation not found."
        case .processingFailed(let message):
            return "Processing failed: \(message)"
        }
    }
}
