//
//  ActionPriceView.swift
//  EthGasTracker
//
//  Created by Tem on 8/5/23.
//

import SwiftUI

struct ActionPriceListView: View {
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
                    VStack(alignment: .center) {
                        HStack {
                            Spacer()
                        }
                        NormalFastView(
                            normal: action.lastEntry()?.value.normal ?? 0,
                            fast: action.lastEntry()?.value.fast ?? 0,
                            currency: "usd"
                        ).padding(.vertical)
                        Text(action.metadata.name)
                            .bold()
                            
                        Divider()
                        Text(addSpacesToCamelCase(groupName))
                            .font(.caption)
                            .textCase(.uppercase)
                            .foregroundColor(Color.secondary)
                        
//                        Divider()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .background(LinearGradient(colors: gradient, startPoint: .bottomLeading, endPoint: .topTrailing).opacity(0.4))
                    .cornerRadius(15)
                    .overlay( /// apply a rounded border
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }
}

func addSpacesToCamelCase(_ str: String) -> String {
    return str.reduce("") { result, character in
        if character.isUppercase {
            return result + " " + character.lowercased()
        }
        return result + String(character)
    }
}

let exampleEntries: [String: NormalFast] = [
    "1609459200": NormalFast(normal: 10.0, fast: 20.0),
    "1609545600": NormalFast(normal: 15.0, fast: 25.0),
    "1609632000": NormalFast(normal: 12.0, fast: 22.0)
]

let m1 = Metadata(name: "Sample Action 1", groupName: "group1", key: "a1", limit: 1000)
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
        ActionPriceListView(actions: previewActions)
            .padding()
    }
}
