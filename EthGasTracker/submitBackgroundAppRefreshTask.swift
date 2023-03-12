//
//  submitBackgroundAppRefreshTask.swift
//  EthGasTracker
//
//  Created by Tem on 3/10/23.
//

import SwiftUI
import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
 
  func applicationDidEnterBackground(_ application: UIApplication) {
    submitBackgroundTasks()
  }
  
  func submitBackgroundTasks() {
    // Declared at the "Permitted background task scheduler identifiers" in info.plist
    let backgroundAppRefreshTaskSchedulerIdentifier = "com.example.fooBackgroundAppRefreshIdentifier"
    let timeDelay = 10.0

    do {
      let backgroundAppRefreshTaskRequest = BGAppRefreshTaskRequest(identifier: backgroundAppRefreshTaskSchedulerIdentifier)
      backgroundAppRefreshTaskRequest.earliestBeginDate = Date(timeIntervalSinceNow: timeDelay)
      try BGTaskScheduler.shared.submit(backgroundAppRefreshTaskRequest)
      print("Submitted task request")
    } catch {
      print("Failed to submit BGTask")
    }
  }
}
