//
//  Endpoints.swift
//  EthGasTracker
//
//  Created by Tem on 1/21/24.
//

import Foundation

struct Endpoints {
    let PROD = "http://135.181.194.46:8080"
    let DEV = "http://127.0.0.1:8080"
    let AMOUNT_TO_FETCH = 90

    let latest: String
    let historyHour: String
    let historyDay: String
    let historyWeek: String
    let historyMonth: String
    
    let getAlerts: String
    let addAlert: String
    let toggleAlert: String
    let deleteAlert: String
    
    let stats: String
    
    init () {
        let env = self.PROD
        self.latest = env + "/api/v3/latest" + "?amount=" + String(AMOUNT_TO_FETCH)
        self.historyHour =  env + "/api/v3/history/hour"
        self.historyDay =  env + "/api/v3/history/day"
        self.historyWeek =  env + "/api/v3/history/week"
        self.historyMonth =  env + "/api/v3/history/month"
        
        self.getAlerts = env + "/api/v1/alerts/list"
        self.addAlert = env + "/api/v1/alerts/add"
        self.toggleAlert = env + "/api/v1/alerts/toggle"
        self.deleteAlert = env + "/api/v1/alerts/delete"
        
        self.stats = env + "/api/v1/stats"
    }
}
