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
        HStack(alignment: .top) {
            ActionNameView(name: action.metadata.name)
            Spacer()
            DiffValueView(baseValue: lastValue, targetValue: selectedValue)
                .font(.system(.body, design: .monospaced))
                .padding(.trailing)
            
            if (selectedValue != nil) {
                Text(String(format: "$%.2f", selectedValue!))
                    .font(.system(.body, design: .monospaced))
            } else {
                Text(String(format: "$%.2f", lastValue))
                    .font(.system(.body, design: .monospaced))
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
