//
//  AlertVM.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import Foundation


class AlertVM: ObservableObject {
    let apiManager: APIManager
    @Published var alerts: [Alert] = []
    let FREE_ALERTS_LIMIT = 1
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
        fetch()
    }
    
    func existsById(id: String) -> Bool {
        return alerts.contains(where: { $0.id == id })
    }
    
    func exists(alert: Alert?) -> Bool {
        guard let alert = alert else { return false }
        for existingAlert in alerts {
            guard alert.deviceId == existingAlert.deviceId,
                  alert.mutePeriod == existingAlert.mutePeriod,
                  alert.confirmationPeriod == existingAlert.confirmationPeriod,
                  doDisabledHoursOverlap(alert1: existingAlert, alert2: alert),
                  areAlertConditionsEquivalent(existingAlert: existingAlert, alertToCompare: alert) else {
                continue
            }
            return true
        }
        
        return false
    }
    
    private func doDisabledHoursOverlap(alert1: Alert, alert2: Alert) -> Bool {
        guard let alert1From = alert1.disabledHours.first, let alert1To = alert1.disabledHours.last,
              let alert2From = alert2.disabledHours.first, let alert2To = alert2.disabledHours.last else {
            // If either alert does not have complete disabled hours, consider them overlapping
            return true
        }

        // Check for direct overlap
        let directOverlap = (alert1From < alert2To && alert1To > alert2From) || (alert2From < alert1To && alert2To > alert1From)

        // Handle "from" greater than "to" scenario for both alerts
        let alert1CrossesMidnight = alert1From > alert1To
        let alert2CrossesMidnight = alert2From > alert2To

        // Check for overlap when one or both periods cross midnight
        let crossesMidnightOverlap = (alert1CrossesMidnight && (alert2From < alert1To || alert2To > alert1From)) ||
                                     (alert2CrossesMidnight && (alert1From < alert2To || alert1To > alert2From))

        return directOverlap || crossesMidnightOverlap
    }

    
    private func areAlertConditionsEquivalent(existingAlert: Alert, alertToCompare: Alert) -> Bool {
        guard let existingAlertCondition = existingAlert.conditions.first(where: { $0.value != 0 }),
              let alertCondition = alertToCompare.conditions.first(where: { $0.value != 0 }),
              existingAlertCondition.comparison == alertCondition.comparison,
              existingAlertCondition.value == alertCondition.value else {
            return false
        }

        return true
    }


    
    func fetch() {
        if let deviceToken = DeviceTokenManager.shared.deviceToken {
            self.apiManager.getAlerts(by: deviceToken) { result in
                DispatchQueue.main.async {
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
        self.apiManager.addAlert(alert) { result in
            switch result {
            case .success(let responseId):
                DispatchQueue.main.async {
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
                }
                case .failure(let error):
                    print("error while adding alert")
                    print(error)
                }
            }
        }
    
    func update(alert: Alert) {
        apiManager.updateAlert(alert) { result in
            guard let index = self.alerts.firstIndex(where: { $0.id == alert.id }) else {
                print("Alert with ID \(alert.id ?? "nil") not found")
                return
            }

            let fallbackAlerts = self.alerts
            DispatchQueue.main.async {
                self.alerts[index] = alert
            }

            switch result {
            case .success():
                return
            case .failure(let error):
                print("error while updating \(alert.id ?? "nil")")
                print(error)

                DispatchQueue.main.async {
                    self.alerts = fallbackAlerts
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
