//
//  ThresholdStorage.swift
//  EthGasTracker
//
//  Created by Tem on 4/15/23.
//

import Foundation
import SwiftUI

@propertyWrapper
struct ThresholdsStorage: DynamicProperty {
    @AppStorage private var data: Data?
    private let key: String
    private let defaultValue: [Threshold]

    init(wrappedValue: [Threshold], key: String) {
        self.defaultValue = wrappedValue
        self.key = key
        self._data = AppStorage(key)
        if let data = UserDefaults.standard.data(forKey: key) {
            let decodedValue = try? JSONDecoder().decode([Threshold].self, from: data)
            self._data.wrappedValue = decodedValue != nil ? try? JSONEncoder().encode(decodedValue) : nil
        } else {
            self._data.wrappedValue = nil
        }
    }

    var wrappedValue: [Threshold] {
        get {
            if let data = data {
                return (try? JSONDecoder().decode([Threshold].self, from: data)) ?? defaultValue
            } else {
                return defaultValue
            }
        }
        nonmutating set {
            data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}


struct Threshold: Identifiable, Equatable, RawRepresentable, Codable {
    var id = UUID()
    let thresholdPrice: Double
    let comparison: String
    let mute_duration: Int
    var enabled: Bool?

    init(thresholdPrice: Double, comparison: String, mute_duration: Int, enabled: Bool?) {
        self.thresholdPrice = thresholdPrice
        self.comparison = comparison
        self.mute_duration = mute_duration
        self.enabled = true
    }

    init?(rawValue: [String: Any]) {
        guard let thresholdPrice = rawValue["thresholdPrice"] as? Double,
              let comparison = rawValue["comparison"] as? String,
              let mute_duration = rawValue["mute_duration"] as? Int else { return nil }
        self.thresholdPrice = thresholdPrice
        self.comparison = comparison
        self.mute_duration = mute_duration
        self.enabled = true
    }

    var rawValue: [String: Any] {
        return ["thresholdPrice": thresholdPrice, "comparison": comparison]
    }
}
