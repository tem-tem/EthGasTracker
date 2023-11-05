//
//  ActionPriceView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI


struct PriceView2: View {
    var selectedKey: String?
    var action: ActionEntity
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    var lastValue: Float {
        let normalFast = action.lastEntry()?.value ?? NormalFast(normal: 0, fast: 0)
        return isFastMain ? normalFast.fast : normalFast.normal
    }
    
    var selectedValue: Float? {
        guard let key = selectedKey,
              let normalFast = action.entries[key] else {
            return nil
        }
        
        return isFastMain ? normalFast.fast : normalFast.normal
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(String(format: "$%.2f", selectedValue ?? lastValue))
                .font(.system(selectedValue != nil ? .title3 : .title2, design: .monospaced))
                .bold(selectedValue == nil)
                .padding(.bottom, 6)
//                .padding(.bottom, selectedValue == nil ? 0 : 6)
            if (selectedValue != nil) {
                Divider()
                DiffValueView(baseValue: lastValue, targetValue: selectedValue)
                    .font(.system(.caption, design: .monospaced))
                    .padding(.vertical, 4)
            }
        }.frame(height: 50)
    }
}

struct ActionsPriceListView: View {
    @Binding var selectedKey: String?
    var actions: [Dictionary<String, [ActionEntity]>.Element]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    private let gradient: [Color] = [Color("avg"), Color("avgLight"), Color("avg")]
    
    //    @AppStorage(SettingsKeys().colorScheme) private var settingsColorScheme: ColorScheme = .none
    //    @Environment(\.colorScheme) private var defaultColorScheme
    //    private var gradient: [Color] {
    //        if defaultColorScheme == .light ||
    //            (
    //                defaultColorScheme == .none && defaultColorScheme == .light
    //            ) {
    //            return [Color("avg"), Color("avgLight"), Color("avg")]
    //        }
    //        return [Color("avgLight"), Color("avg"), Color("avgLight")]
    //    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(actions, id: \.key) { groupName, groupAction in
                ForEach(groupAction.sorted(by: {$0.metadata.name < $1.metadata.name}), id: \.metadata.key) {action in
                    VStack (alignment: .leading) {
                        VStack(alignment: .center) {
                            HStack {
                                Spacer()
                            }
                            PriceView2(selectedKey: selectedKey, action: action)
                        }
//                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        Text(action.metadata.name)
                            .font(.caption)
                            .bold()
                            .textCase(.uppercase)
                            .padding(.bottom, -5)
                        
                        Text(addSpacesToCamelCase(groupName))
                            .font(.caption)
                            .textCase(.uppercase)
                            .foregroundColor(Color.secondary)
                    }
                    .padding(.bottom, 10)
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

struct ActionPriceListView_Previews: PreviewProvider {
    
    static var previews: some View {
        ActionsPriceListView(selectedKey: .constant("1"), actions: previewActions)
            .padding()
    }
}
