//
//  ActionsListFocusView.swift
//  EthGasTracker
//
//  Created by Tem on 8/20/23.
//

import SwiftUI
struct HeaderView: View {
    var groupName: String
    var body: some View {
        Text(addSpacesToCamelCase(groupName))
            .font(.caption)
            .textCase(.uppercase)
            .foregroundColor(Color.secondary)
        Divider()
    }
}

struct ActionNameView: View {
    var name: String
    var body: some View {
        Text(name)
    }
}

struct PriceView: View {
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
        HStack {
            ActionNameView(name: action.metadata.name)
            Spacer()
            if let selectedVal = selectedValue,
               let diff = lastValue - selectedVal,
               diff != 0
            {
                HStack {
                    if (diff > 0) {
                        Image(systemName: "arrow.down")
                    } else {
                        Image(systemName: "arrow.up")
                    }
                    Text(abs(diff), format: .currency(code: "usd"))
                }
                .font(.system(size: 18, weight: .regular, design: .monospaced))
                .opacity(0.5)
//                Spacer()
                .padding(.trailing)
//                .foregroundStyle(diff > 0 ? Color(.systemGreen) : Color(.systemRed))
            }
            
            if (selectedValue != nil) {
                
                Text(
                    selectedValue!,
                    format: .currency(code: "usd")
                )
    //                .padding(.vertical)
                .font(.system(size: 18, weight: .regular, design: .monospaced))
            } else {
                Text(
                    lastValue,
                    format: .currency(code: "usd")
                )
    //                .padding(.vertical)
                .font(.system(size: 18, weight: .regular, design: .monospaced))
            }
        }
        
    }
}

struct ActionsListFocusView: View {
    var actions: [Dictionary<String, [ActionEntity]>.Element]
    @Binding var selectedKey: String?
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack() {
            ForEach(actions, id: \.key) { groupName, groupAction in
                VStack(alignment: .leading) {
                    HeaderView(groupName: groupName)
                    ForEach(groupAction.sorted(by: {$0.metadata.name < $1.metadata.name}), id: \.metadata.key) { action in
                        PriceView(selectedKey: selectedKey, action: action)
                        Divider()
                    }
                }.padding(.bottom)
            }
        }
    }
}


struct ActionsListFocusView_Previews: PreviewProvider {
    static var previews: some View {
        ActionsListFocusView(actions: previewActions, selectedKey: .constant("1609545600"))
            .padding()
    }
}
