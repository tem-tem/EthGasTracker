//
//  AppDelegate.swift
//  EthGasTracker
//
//  Created by Tem on 3/10/23.
//

import SwiftUI
import BackgroundTasks

class OP: Operation {
    @AppStorage("test") var test = 1
    
    override func main() {
        print("OPERATION RAN")
        test = test + 100
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    @AppStorage("test") var test = 1
    @Published var deviceToken: String?

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
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
        
        print("LAUNCHED")
        let a = BGTaskScheduler.shared.register(forTaskWithIdentifier: "IDENTIFIER", using: nil) { task in
            print("REGISTERED")
            self.test = self.test + 1
            self.handleSchedule(task: task as! BGAppRefreshTask)
        }
        print("this -> \(a)")
        return true
    }
    
     func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: "IDENTIFIER")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1)
        
       do {
          try BGTaskScheduler.shared.submit(request)
           print("submitted")
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }
    
     func handleSchedule(task: BGAppRefreshTask) {
        print("HANDLING SCHEDULE")
        schedule()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operation = OP()

        
        task.expirationHandler = {
            print("BG Task Expired")
            queue.cancelAllOperations()
        }
        
        operation.completionBlock = {
            print("OPERATION COMPLETED")
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        queue.addOperation(operation)
    }
}
