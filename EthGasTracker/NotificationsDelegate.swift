//
//  NotificationsDelegate.swift
//  EthGasTracker
//
//  Created by Tem on 4/14/23.
//

import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // This method will be called when the app is in the foreground and a notification is received.
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // This method will be called when the user interacts with the notification (e.g. tap, dismiss).
        completionHandler()
    }
}
