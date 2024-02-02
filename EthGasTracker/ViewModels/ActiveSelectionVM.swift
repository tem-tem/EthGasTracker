//
//  ActiveSelectionViewModel.swift
//  EthGasTracker
//
//  Created by Tem on 1/8/24.
//

import Foundation

class ActiveSelectionVM: ObservableObject {
    @Published var date: Date? = nil
    @Published var gas:Double? = nil
    @Published var key: String? = nil
    @Published var index: Int? = nil
    @Published var historicalData: HistoricalData? = nil
    @Published var chartType: ChartTypes = .live
    
    @Published var currentTime: Date = Date.now
    
    var updateCurrentTime: RepeatingTask {
        RepeatingTask(interval: 1) {
            self.currentTime = Date.now
        }
    }
    
    init() {
        self.updateCurrentTime.start()
    }
    
    func isActive() -> Bool {
        return gas != nil || historicalData != nil
    }
    
    func drop() -> Void {
        self.date = nil
        self.gas = nil
        self.key = nil
        self.index = nil
        self.historicalData = nil
    }
}
