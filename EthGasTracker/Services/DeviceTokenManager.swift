//
//  DeviceTokenManager.swift
//  EthGasTracker
//
//  Created by Tem on 1/22/24.
//

import Foundation

//TODO: find a case where this is unavailable
class DeviceTokenManager {
    static let shared = DeviceTokenManager()
    private init() {}

    private var _deviceToken: String?
    private let tokenQueue = DispatchQueue(label: "com.EthGasTracker.DeviceTokenManager")

    var deviceToken: String? {
        get {
            print("Device token get: \(tokenQueue.sync { _deviceToken } ?? "nil")")
            return tokenQueue.sync { _deviceToken }
        }
        set(newToken) {
            print("Device token set: \(newToken ?? "nil")")
            tokenQueue.sync { _deviceToken = newToken }
        }
    }
}
