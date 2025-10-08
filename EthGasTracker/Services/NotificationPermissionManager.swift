//
//  NotificationPermissionManager.swift
//  EthGasTracker
//
//  Created by Tem on 10/13/24.
//

import UserNotifications

class NotificationPermissionManager {
    static let shared = NotificationPermissionManager()
    private init() {}

    // Check the current notification authorization status
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    // Request notification permission (just the permission, without remote notification registration)
    // Extension-safe: caller can supply onGranted to register for remote notifications from the app target.
    func requestNotificationPermission(onGranted: (() -> Void)? = nil, completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
                completion(false)
                return
            }
            if granted { onGranted?() }
            completion(granted)
        }
    }

    // Set the device token once it is received
    func setDeviceToken(_ deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        DeviceTokenManager.shared.deviceToken = tokenString
        print("Device token set: \(tokenString)")
    }
}
