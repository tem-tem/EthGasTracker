//
//  ReferralCodeManager.swift
//  EthGasTracker
//
//  Created by Tem on 9/29/24.
//


import Foundation

class ReferralCodeManager {
    
    // Singleton instance
    static let shared = ReferralCodeManager()
    
    // Key for referral code in iCloud
    private let referralCodeKey = "referralCodeKey"
    private let secretCodeKey = "secretCodeKey"
    
    private init() {}
    
    // Get the NSUbiquitousKeyValueStore instance
    private var iCloudStore: NSUbiquitousKeyValueStore {
        return NSUbiquitousKeyValueStore.default
    }
    
    // Function to set referral code
    func setReferralCode(_ code: String) {
        iCloudStore.set(code, forKey: referralCodeKey)
        iCloudStore.synchronize()
    }
    
    // Function to retrieve the referral code
    func getReferralCode() -> String? {
        iCloudStore.synchronize()
        return iCloudStore.string(forKey: referralCodeKey)
    }
    
    func getSecretCode() -> String {
        iCloudStore.synchronize()
        if let secret = iCloudStore.string(forKey: secretCodeKey) {
            return secret
        } else {
            let secret = generateSecretCode()
            iCloudStore.set(secret, forKey: secretCodeKey)
            iCloudStore.synchronize()
            return secret
        }
    }
    
    // Function to check if referral code exists
    func hasReferralCode() -> Bool {
        iCloudStore.synchronize()
        return iCloudStore.string(forKey: referralCodeKey) != nil
    }
    
    func clearReferralCode() {
        #if DEBUG
        iCloudStore.removeObject(forKey: referralCodeKey)
        iCloudStore.synchronize()
        #endif
    }
    
    // Function to generate a random alphanumeric referral code
    private func generateSecretCode(length: Int = 12) -> String {
        let letters = "qwertyuioopasdfghjklzxcvbnmABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }

}
