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

struct LegacyGasData {
    var low: Float;
    var avg: Float;
    var high: Float;
}

struct NormalFast {
    var normal: Float;
    var fast: Float;
}

struct Action {
    var action: String;
    var price: NormalFast;
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var deviceToken: String?
    @Published var ethPrice: Float = 0.0
    @Published var legacyGas: LegacyGasData = LegacyGasData(low: 0, avg: 0, high: 0)
    @Published var gas = NormalFast(normal: 0.0, fast: 0.0)
    @Published var actions: [Action] = []
    
    var dataManager = DataManager()
    
    
    var repeatedFetch: RepeatingTask {
        RepeatingTask(interval: 10.0) {
            self.dataManager.fetchAndStoreData(amount: 1) { result in
                switch result {
                case .success(let entities):
                    print("Successfully fetched and stored data")
                    DispatchQueue.main.async {
                        self.ethPrice = entities.priceEntities.first?.price ?? 0.0
                        self.legacyGas = LegacyGasData(
                            low: entities.legacyGasEntities.first?.low ?? 0.0,
                            avg: entities.legacyGasEntities.first?.avg ?? 0.0,
                            high: entities.legacyGasEntities.first?.high ?? 0.0
                        )
                        self.gas = NormalFast(
                            normal: entities.gasEntities.first?.normal ?? 0.0,
                            fast: entities.gasEntities.first?.fast ?? 0.0
                        )
                        var newActions: [Action] = []
                        for (transferPriceEntity) in entities.transferPriceEntities {
                            if let action = transferPriceEntity.action {
                                newActions.append(Action(action: action, price: NormalFast(normal: transferPriceEntity.normal, fast: transferPriceEntity.fast)))
                            }
                        }
                        self.actions = newActions
                        
                    }
                case .failure(let error):
                    print("An error occurred: \(error)")
                }
            }
        }
    }

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
        repeatedFetch.start()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        repeatedFetch.stop()
    }
}
