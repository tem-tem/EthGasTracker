//
//  Currency.swift
//  EthGasTracker
//
//  Created by Tem on 12/9/23.
//

import Foundation

struct Currency: Codable {
    let code: String
    let name: String
}

extension Currency {
    static var sampleCurrencies: [Currency] = [
        Currency(code: "USD", name: "United States Dollar"),
        Currency(code: "EUR", name: "Euro"),
        Currency(code: "GBP", name: "British Pound"),
        Currency(code: "JPY", name: "Japanese Yen"),
    ]
}

class CurrencyViewModel: ObservableObject {
    @Published var currencies: [Currency] = []

    init() {
        loadCurrencies()
    }
    
    func getByCode(code: String) -> Currency? {
        return currencies.first(where: { $0.code == code })
    }

    func loadCurrencies() {
        guard let url = Bundle.main.url(forResource: "CurrencyList", withExtension: "json") else {
            print("Currencies JSON file not found.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let loadedCurrencies = try decoder.decode([Currency].self, from: data)
            self.currencies = loadedCurrencies
        } catch {
            print("Error loading currencies: \(error)")
        }
    }
}

func getSymbol(forCurrencyCode code: String) -> String? {
   let locale = NSLocale(localeIdentifier: code)
    return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code)
}
