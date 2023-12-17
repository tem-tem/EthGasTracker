//
//  ActionPriceView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI


struct ActionPriceBoxView: View {
    var selectedKey: String?
    var action: ActionEntity
    @Binding var selectedHistoricalData: HistoricalData?
    
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    @AppStorage("currency") var currency: String = "USD"
    var currencyCode: String {
        return getSymbol(forCurrencyCode: currency) ?? currency
    }
    
    var lastValue: Float {
        let normalFast = action.lastEntry()?.value ?? NormalFast(normal: 0, fast: 0)
        return isFastMain ? normalFast.fast : normalFast.normal
    }
    
    var selectedValue: Float? {
        if let historical = selectedHistoricalData {
            
//            let normal = (Float(String(format: "%.6f", (gasEntry.normal * Float(metadata.limit)) / 1e9)) ?? 0) * (ethPrices[timestamp] ?? 0)
            let gas = historical.avg
            let ethPrice = historical.price
            let limit = Float(action.metadata.limit)
            return (gas * limit / 1e9) * ethPrice
        }
        guard let key = selectedKey,
              let normalFast = action.entries[key] else {
            return nil
        }
        
        return isFastMain ? normalFast.fast : normalFast.normal
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(String(format: "\(currencyCode.count == 1 ? currencyCode : "")%.2f", selectedValue ?? lastValue))
                .font(.system(selectedValue != nil ? .title3 : .title2, design: .monospaced))
                .bold(selectedValue == nil)
                .padding(.bottom, 6)
//                .padding(.bottom, selectedValue == nil ? 0 : 6)
            if (selectedValue != nil) {
                Divider()
                if (selectedValue != nil) {
                    DiffValueView(baseValue: lastValue, targetValue: selectedValue)
                        .font(.system(.caption, design: .monospaced))
                        .padding(.vertical, 4)
                } else {
                    Text("=")
                        .opacity(0.5)
                        .font(.system(.caption, design: .monospaced))
                        .padding(.vertical, 4)
                }
            }
        }.frame(height: 50)
    }
}

struct ActionsGridView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @Binding var selectedKey: String?
    var actions: GroupedActions
    @Binding var selectedHistoricalData: HistoricalData?
    var isActiveSelection: Bool
//    var isActiveSelection: Bool
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @AppStorage("currency") var currency: String = "USD"
    var currencyCode: String {
        return getSymbol(forCurrencyCode: currency) ?? currency
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(actions.sorted(by: {$0.key < $1.key}), id: \.key) { groupName, groupAction in
                    ForEach(groupAction.sorted(by: {$0.metadata.name < $1.metadata.name}), id: \.metadata.key) {action in
                        VStack (alignment: .leading) {
                            VStack(alignment: .center) {
                                HStack {
                                    Spacer()
                                }
                                ActionPriceBoxView(selectedKey: selectedKey, action: action, selectedHistoricalData: $selectedHistoricalData)
                                    .foregroundColor(isActiveSelection ? .primary : appDelegate.gasLevel.color)
                            }
    //                        .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
    //                                .stroke( selectedKey == nil ? appDelegate.gasLevel.color.opacity(0.3) : Color.secondary.opacity(0.3), lineWidth: 1)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                            Text(action.metadata.name)
                                .font(.caption)
                                .bold()
                                .textCase(.uppercase)
                                .padding(.bottom, -5)
                                .foregroundColor(Color.secondary)
                            
                            Text(addSpacesToCamelCase(groupName))
                                .font(.caption)
                                .textCase(.uppercase)
                                .foregroundColor(Color.secondary)
                                .opacity(0.5)
    //                            .foregroundColor(selectedKey == nil ? appDelegate.gasLevel.color.opacity(0.75) : Color.secondary)
                        }
                        .padding(.bottom, 5)
    //                    .foregroundColor(selectedKey == nil ? appDelegate.gasLevel.color : .primary)
                    }
                }
            }
        }
    }
}

func addSpacesToCamelCase(_ str: String) -> String {
    var result = ""
    for char in str {
        if char.isUppercase {
            result.append(" ")
        }
        result.append(char)
    }
    result.removeFirst()
    return result
}

let exampleEntries: [String: NormalFast] = [
    "1609459200": NormalFast(normal: 10.0, fast: 20.0),
    "1609545600": NormalFast(normal: 15.0, fast: 25.0),
    "1609632000": NormalFast(normal: 12.0, fast: 22.0)
]

let m1 = Metadata(name: "Sample Action 1 Sample Action 1", groupName: "group1", key: "a1", limit: 1000)
let m2 = Metadata(name: "Sample Action 2", groupName: "group1", key: "a2", limit: 1000)
let m3 = Metadata(name: "Sample Action 3", groupName: "group3", key: "a3", limit: 1000)

let a1 = ActionEntity(entries: exampleEntries, metadata: m1)
let a2 = ActionEntity(entries: exampleEntries, metadata: m2)
let a3 = ActionEntity(entries: exampleEntries, metadata: m3)

let previewActions: [Dictionary<String, [ActionEntity]>.Element] = [
    (key: "group1", value: [a1, a2]),
    (key: "group2", value: [a3])
]

//struct ActionPriceListView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        ActionsPriceListView(selectedKey: .constant("1"), actions: previewActions)
//            .padding()
//    }
//}
