//
//  DeviceTokenManager.swift
//  EthGasTracker
//
//  Created by Tem on 1/22/24.
//

import Foundation

class DeviceTokenManager {
    static let shared = DeviceTokenManager()
    private init() {}

    private var _deviceToken: String?
    private let tokenQueue = DispatchQueue(label: "com.EthGasTracker.DeviceTokenManager")

    var deviceToken: String? {
        get {
            return tokenQueue.sync { _deviceToken }
        }
        set(newToken) {
            tokenQueue.sync { _deviceToken = newToken }
        }
    }
}
