//
//  DeviceIdManager.swift
//  BirdId
//
//  Created by ali bakhsha on 9/2/1404 AP.
//

import Foundation
import KeychainAccess

class DeviceIDManager {
    static let shared = DeviceIDManager()
    private init() {}

    private let keychain = Keychain(service: "com.birdid.app.deviceid")
        .accessibility(.always)
        .synchronizable(false)

    private let deviceIDKey = "persistent_device_uuid"

    private var cachedId: String?

    /// Always returns one consistent UUID
    func getDeviceUUID() -> String {
        // Return cached
        if let cachedId = cachedId { return cachedId }

        // Check Keychain
        if let saved = try? keychain.getString(deviceIDKey) {
            cachedId = saved
            return saved
        }

        // Create and save new one
        let newUUID = UUID().uuidString
        do {
            try keychain.set(newUUID, key: deviceIDKey)
        } catch {
            print("⚠️ Failed to store deviceId in Keychain → \(error)")
        }

        cachedId = newUUID
        return newUUID
    }

    /// For debugging only
    func resetDeviceUUID() -> String {
        let newUUID = UUID().uuidString
        try? keychain.set(newUUID, key: deviceIDKey)
        cachedId = newUUID
        return newUUID
    }
}
