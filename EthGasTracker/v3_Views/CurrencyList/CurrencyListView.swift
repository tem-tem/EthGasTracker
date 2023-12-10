//
//  CurrencyListView.swift
//  EthGasTracker
//
//  Created by Tem on 12/9/23.
//

import Foundation
import SwiftUI

struct CurrencyListButtonView: View {
    @State private var showingSheet = false
    @ObservedObject var viewModel = CurrencyViewModel()
    @AppStorage("subbed") var subbed: Bool = false
    @AppStorage("currency") var currency: String = "USD"
    var currencyCode: String {
        return getSymbol(forCurrencyCode: currency) ?? currency
    }
    

    var body: some View {
        Button(action: {
            showingSheet = true
        }) {
            HStack {
                Image(systemName: "arrow.left.arrow.right.circle")
                    .frame(width: 32, height: 32)
                    .background(.purple, in: RoundedRectangle(cornerRadius: 8))
                    .foregroundColor(.white)
                Text("Currency")
                    .foregroundColor(.primary)
                Spacer()
                if (subbed) {
                    Text(currencyCode.count == 1 ? "\(currency) (\(currencyCode))" : currencyCode)
                        .font(.system(.body, design: .monospaced))
                } else {
                    Text("Unlock")
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        .sheet(isPresented: $showingSheet) {
            if (subbed) {
                CurrencyListView(currencies: viewModel.currencies, onSelect: {
                    currency = $0.code
                    showingSheet = false
                })
            } else {
                PurchaseView()
            }
        }
    }
}

struct CurrencyListView: View {
    var currencies: [Currency]
    var onSelect: (Currency) -> Void
    @AppStorage("currency") var active_currency: String = "USD"
    @State private var searchText = ""

    var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return currencies
        } else {
            return currencies.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        VStack {
            Text("Currency").font(.title).bold().padding()
            Text("Eth price and actions will by converted to the selected currency. Change takes effect in 5-10 seconds.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
                .padding(.horizontal)
            TextField("Search Currencies", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            List {
                ForEach(filteredCurrencies, id: \.code) { currency in
                    Button {
                        onSelect(currency)
                    } label: {
                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
                                Text(currency.name)
                                    .font(.subheadline)
                                Spacer()
                                Text(getSymbol(forCurrencyCode: currency.code) ?? currency.code)
                                    .font(.system(.headline, design: .monospaced))
                            }.foregroundStyle(currency.code == active_currency ? Color.accentColor : .primary)

                            if currency.code == active_currency {
                                Text("Selected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
