//
//  Alerts.swift
//  EthGasTracker
//
//  Created by Tem on 12/15/23.
//

import Foundation

extension AppDelegate {
    func cleanUpAlerts() {
        // Filter out premium alerts
        let nonPremiumAlerts = self.alerts.filter { !$0.isPremium() }

        // Keep only the first three non-premium alerts
        let alertsToKeep = Array(nonPremiumAlerts.prefix(FREE_ALERTS_LIMIT))
        
        let idsToDelete = Set(self.alerts.map { $0.id }).subtracting(alertsToKeep.map { $0.id })
        
        if (idsToDelete.count > 0) {
            // Find the IDs of alerts to delete

            // Delete the alerts not in alertsToKeep
            idsToDelete.forEach {
                if let id = $0 {
                    self.deleteAlert(by: id)
                }
            }
            self.fetchAlerts()
        }
    }
    
    func fetchAlerts () {
        guard let deviceId = self.deviceToken else {
            return
        }
        self.api_v1.getAlerts(by: deviceId) { result in
            switch result {
            case .success(let alertsFromResponse):
                DispatchQueue.main.async {
                    self.alerts = alertsFromResponse
                }
            case .failure(let error):
                print("error while fetching alerts")
                print(error)
            }
        }
    }
    
    func toggleAlert(by alertId: String) {
        self.api_v1.toggleAlert(by: alertId) { result in
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
    
    func deleteAlert(by alertId: String) {
        self.api_v1.deleteAlert(by: alertId) { result in
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
    
    func addAlert(alert: GasAlert) {
        self.api_v1.addAlert(alert) { result in
            
            switch result {
            case .success(let newAlertId):
                DispatchQueue.main.async {
                    self.alerts.append(
                        GasAlert(
                            id: newAlertId,
                            deviceId: alert.deviceId,
                            mutePeriod: alert.mutePeriod,
                            conditions: alert.conditions,
                            legacyGas: alert.legacyGas,
                            confirmationPeriod: alert.confirmationPeriod,
                            disableAfterAlerts: alert.disableAfterAlerts,
                            disabledHours: alert.disabledHours
                        ))
                }
                return
            case .failure(let error):
                print("error while adding new alert")
                print(error)
            }
        }
    }
}
