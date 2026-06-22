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
    @Published var birdDetail: BirdDetailResponse?
    @Published var showSearchResult = false
    @Published var showResult = false
    @Published var checkedState: CheckedState?
    @Published var showCheckedView = false
    @Published var showPaywall = false

    // MARK: - Private Properties
    private var cancelBag = Set<AnyCancellable>()
    private let uploadRepo: UploadRepositoryProtocol
    private weak var coordinator: Coordinator?
    
    private var deviceId: String {
        DeviceIDManager.shared.getDeviceUUID()
    }
    
    // MARK: - Constants
    private enum Config {
        static let successDisplayDuration: TimeInterval = 2.5
        static let failureDisplayDuration: TimeInterval = 3.0
    }
    
    // MARK: - Initialization
    init(uploadRepo: UploadRepositoryProtocol = UploadRepository()) {
        self.uploadRepo = uploadRepo
    }
    
    func setCoordinator(_ coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Public Methods
    func uploadImage(_ data: Data) {
        uploadMedia(data, type: .image)
    }
    
    func uploadAudio(_ data: Data) {
        uploadMedia(data, type: .audio)
    }
    
    func cleanup() {
        cancelBag.removeAll()
    }
    
    // MARK: - Private Methods
    private func uploadMedia(_ data: Data, type: MediaType) {
        // Paywall gate: identification requires an active subscription / free trial.
        if !SubscriptionManager.shared.isPremium {
            showPaywall = true
            return
        }

        isLoading = true
        errorMessage = nil
        showSearchResult = true
        birdDetail = nil
        
        uploadRepo.uploadAndIdentify(
            file: data,
            deviceId: deviceId,
            type: type.rawValue
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.handleCompletion(completion)
        } receiveValue: { [weak self] uploadResponse in
            self?.handleSuccess(uploadResponse)
        }
        .store(in: &cancelBag)
    }

    private func handleSuccess(_ bird: UploadResponse) {
        self.birdDetail = bird.bird
        self.showSearchResult = false
        self.checkedState = .success
        self.showCheckedView = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self else { return }
            self.showCheckedView = false
            self.coordinator?.push(.ResultScreen(uploadResponse: bird))
        }
    }

    private func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        isLoading = false
        
        switch completion {
        case .finished:
            print("درخواست با موفقیت تمام شد (ولی ممکنه success قبلاً فراخوانی شده باشه)")
            
        case .failure(let error):
        
            if let urlError = error as? URLError {
                print("   URLError Code: \(urlError.code.rawValue)")
                print("   URLError Description: \(urlError.localizedDescription)")
                switch urlError.code {
                case .timedOut:
                    print("   دلیل: تایم‌اوت — سرور پاسخ نداد")
                case .notConnectedToInternet:
                    print("   دلیل: اینترنت قطع است")
                case .cannotFindHost, .cannotConnectToHost:
                    print("   دلیل: سرور پیدا نشد (آدرس اشتباه یا داون)")
                default:
                    print("   کد خطا: \(urlError.code.rawValue)")
                }
            }
            else {
                print("   Error Type: \(type(of: error))")
                print("   Error: \(error)")
                print("   Localized: \(error.localizedDescription)")
            }
            
            handleFailure(error: error)
        }
    }
    
    private func handleFailure(error: Error) {
        showSearchResult = false
        checkedState = .failure
        showCheckedView = true
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = "اتصال به اینترنت برقرار نیست"
            case .timedOut:
                errorMessage = "سرور پاسخ نداد، لطفاً دوباره تلاش کنید"
            default:
                errorMessage = "خطا در ارتباط با سرور"
            }
        }
        else {
            errorMessage = error.localizedDescription
        }
        
        print("نمایش خطا به کاربر: \(errorMessage ?? "نامشخص")")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Config.failureDisplayDuration) { [weak self] in
            // IdentifyScreen is a tab root; pop here is a no-op or pops the wrong screen.
            // Just dismiss the error overlay and stay on this screen for retry.
            self?.showCheckedView = false
        }
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
