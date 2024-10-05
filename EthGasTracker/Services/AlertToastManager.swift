//
//  AlertToastManager.swift
//  EthGasTracker
//
//  Created by Tem on 10/4/24.
//

import Foundation
import AlertToast

class AlertToastManager: ObservableObject {
    @Published var isShowing = false
    @Published var type: AlertToast.AlertType = .regular
    @Published var message: String = ""
    @Published var displayMode: AlertToast.DisplayMode = .alert
    
    func showError(_ text: String, displayMode dM: AlertToast.DisplayMode = .alert) {
        DispatchQueue.main.async { [self] in
            isShowing = true
            type = .error(.red)
            message = text
            displayMode = dM
        }
    }
    
    func showSuccess(_ text: String, displayMode dM: AlertToast.DisplayMode = .alert) {
        DispatchQueue.main.async { [self] in
            isShowing = true
            type = .complete(.blue)
            message = text
            displayMode = dM
        }
    }
}
