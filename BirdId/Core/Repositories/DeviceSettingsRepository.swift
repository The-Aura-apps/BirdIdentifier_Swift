//
//  DeviceSettingsRepository.swift
//  BirdId
//
//  Created by ali bakhsha on 10/8/1404 AP.
//

import Foundation
import Combine
import Alamofire

protocol DeviceSettingsRepositoryProtocol {
    func sendDeviceSettings(
        identificationMethod: IdentificationMethod,
        userPurpose: UserPurpose
    ) -> AnyPublisher<DeviceSettingsResponse, Error>
}

class DeviceSettingsRepository: DeviceSettingsRepositoryProtocol {
    
    private let apiService: ApiServiceProtocol
    
    init(apiService: ApiServiceProtocol = ApiService()) {
        self.apiService = apiService
    }
    
    func sendDeviceSettings(
        identificationMethod: IdentificationMethod,
        userPurpose: UserPurpose
    ) -> AnyPublisher<DeviceSettingsResponse, Error> {
        
        let deviceId = DeviceIDManager.shared.getDeviceUUID()
        
        let parameters: [String: Any] = [
            "deviceId": deviceId,
            "identificationMethod": identificationMethod.rawValue,
            "userPurpose": userPurpose.rawValue
        ]
        
        return apiService.request(
            Constants.Urls.deviceSettings,
            method: .post,
            body: parameters,
            headers: nil,
            expecting: DeviceSettingsResponse.self
        )
    }
}
