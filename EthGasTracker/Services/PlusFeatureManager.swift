//
//  PlusFeatureManager.swift
//  EthGasTracker
//
//  Created by Tem on 10/3/24.
//

import Foundation

class PlusFeatureManager {
    
    // Singleton instance
    static let shared = PlusFeatureManager()
    
    // Key for premium expiration in iCloud
    private let premiumExpirationKey = "premiumExpirationKey"
    
    private init() {}
    
    // Get the NSUbiquitousKeyValueStore instance
    private var iCloudStore: NSUbiquitousKeyValueStore {
        return NSUbiquitousKeyValueStore.default
    }
    
    // Function to set premium expiration date
    func setPremiumExpirationDate(_ date: Date) {
        let expirationTimestamp = date.timeIntervalSince1970
        iCloudStore.set(expirationTimestamp, forKey: premiumExpirationKey)
        iCloudStore.synchronize()
    }
    
    // Function to get premium expiration date
    func getPremiumExpirationDate() -> Date? {
        iCloudStore.synchronize()
        if let expirationTimestamp = iCloudStore.object(forKey: premiumExpirationKey) as? Double {
            return Date(timeIntervalSince1970: expirationTimestamp)
        }
        return nil
    }
    
    // Function to check if user still has access to premium features
    func hasPremiumAccess() -> Bool {
        if let expirationDate = getPremiumExpirationDate() {
            return Date() < expirationDate
        }
        return false
    }
    
    // Function to get time left for premium access
    func timeLeftForPremium() -> TimeInterval? {
        if let expirationDate = getPremiumExpirationDate() {
            let timeLeft = expirationDate.timeIntervalSinceNow
            return timeLeft > 0 ? timeLeft : nil
        }
        return nil
    }
    
    // Function to clear premium access (for debugging or manual reset)
    func clearPremiumAccess() {
        #if DEBUG
        iCloudStore.removeObject(forKey: premiumExpirationKey)
        iCloudStore.synchronize()
        #endif
    }
}
