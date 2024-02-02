//
//  AlertVM.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import Foundation

let FREE_ALERTS_LIMIT = 1

class AlertVM: ObservableObject {
    let apiManager: APIManager
    @Published var alerts: [Alert] = []
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
        fetch()
    }
    
    func fetch() {
        DispatchQueue.main.async {
            if let deviceToken = DeviceTokenManager.shared.deviceToken {
                self.apiManager.getAlerts(by: deviceToken) { result in
                    switch result {
                    case .success(let responseAlerts):
                        self.alerts = responseAlerts
                    case .failure(let error):
                        print("error while fetching alerts")
                        print(error)
                    }
                }
            }
        }
    }
    
    func add(alert: Alert) {
        DispatchQueue.main.async {
            self.apiManager.addAlert(alert) { result in
                switch result {
                case .success(let responseId):
                    self.alerts.append(
                        Alert(
                            id: responseId,
                            deviceId: alert.deviceId,
                            mutePeriod: alert.mutePeriod,
                            conditions: alert.conditions,
                            legacyGas: alert.legacyGas,
                            confirmationPeriod: alert.confirmationPeriod,
                            disableAfterAlerts: alert.disableAfterAlerts,
                            disabledHours: alert.disabledHours
                        )
                    )
                case .failure(let error):
                    print("error while adding alert")
                    print(error)
                }
            }
        }
    }
    
    func delete(id alertId: String) {
        apiManager.deleteAlert(by: alertId) { result in
            let fallbackAlerts = self.alerts
            DispatchQueue.main.async {
                self.alerts.removeAll(where: { $0.id == alertId })
            }

            switch result {
            case .success():
                return
            case .failure(let error):
                print("error while deleting \(alertId)")
                print(error)

                DispatchQueue.main.async {
                    self.alerts = fallbackAlerts
                }
            }
        }
    }
    
    func toggle(id alertId: String) {
        apiManager.toggleAlert(by: alertId) { result in
            guard let index = self.alerts.firstIndex(where: { $0.id == alertId }) else {
                print("Alert with ID \(alertId) not found")
                return
            }

            let fallbackAlerts = self.alerts
            DispatchQueue.main.async {
                self.alerts[index].disabled = !(self.alerts[index].disabled ?? false)
            }

            switch result {
            case .success():
                return
            case .failure(let error):
                print("error while toggling \(alertId)")
                print(error)

                DispatchQueue.main.async {
                    self.alerts = fallbackAlerts
                }
            }
        }
    }
    
    func cleanUpAlerts() {
        // Filter out premium alerts
        let nonPremiumAlerts = self.alerts.filter { !$0.isPremium() }

        // Keep only the first three non-premium alerts
        let alertsToKeep = Array(nonPremiumAlerts.prefix(FREE_ALERTS_LIMIT))

        let idsToDelete = Set(self.alerts.map { $0.id }).subtracting(alertsToKeep.map { $0.id })

        if (idsToDelete.count > 0) {
            // Delete the alerts not in alertsToKeep
            idsToDelete.forEach {
                if let id = $0 {
                    self.delete(id: id)
                }
            }
            self.fetch()
        }
    }
}
