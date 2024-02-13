//
//  AppDelegate.swift
//  EthGasTracker
//
//  Created by Tem on 3/10/23.
//

import SwiftUI
import BackgroundTasks
import FirebaseCore
import FirebaseAnalytics
import AppTrackingTransparency


class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        DeviceTokenManager.shared.deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//        self.fetchAlerts()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        
        FirebaseApp.configure()
        
        if NSClassFromString("ATTrackingManager") != nil {
            ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        Analytics.logEvent("tracking_authorized", parameters: nil)
                    case .denied:
                        Analytics.logEvent("tracking_denied", parameters: nil)
                    default:
                        break
                }
            }
        }
        Analytics.logEvent("pickup", parameters: nil)
        return true
    }
}
