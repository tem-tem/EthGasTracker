//
//  NotificationTokenObserver.swift
//  EthGasTracker
//
//  Created by Tem on 4/14/23.
//

import Foundation
import SwiftUI
import UIKit

final class NotificationTokenObserver: ObservableObject {
    @Published var deviceToken: String?
    
    private var observer: NSObjectProtocol?

    init() {
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didRegisterForRemoteNotificationsWithDeviceTokenNotification, object: nil, queue: .main) { [weak self] notification in
            if let deviceToken = notification.userInfo?["deviceToken"] as? Data {
                self?.deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
            }
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
