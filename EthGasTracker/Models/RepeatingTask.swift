//
//  RepeatingTask.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import Foundation

class RepeatingTask {

    var timer: Timer?
    var interval: TimeInterval
    var task: (() -> Void)

    init(interval: TimeInterval, task: @escaping (() -> Void)) {
        self.interval = interval
        self.task = task
    }

    func start() {
        stop() // make sure to invalidate any previous timer before starting a new one
        self.task()

        timer = Timer.scheduledTimer(withTimeInterval: self.interval, repeats: true) { _ in
            self.task()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
