//
//  EthGasWidget.swift
//  EthGasWidget
//
//  Created by Tem on 6/15/23.
//

import WidgetKit
import SwiftUI

struct LockscreenRectangularView: View {
    var entry: GasIndexEntry  // Change the type here
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        HStack(alignment: .center) {
            VStack {
                HStack(alignment: .center) {
                    Image(systemName: "flame")
                        .font(.system(size: 20))
                    Text(String(format: "%.f", entry.gasLevel.currentGas))
                        .bold()
                }
                Text(entry.gasLevel.label)
                    .font(.caption)
            }
            Spacer()
        }
        .font(.system(.largeTitle, design: .rounded))
        .minimumScaleFactor(0.1)
        .lineLimit(1)
        .conditionalContainerBackground()
    }
}


struct LockscreenRecktangularWidget: Widget {
    let kind: String = "LockscreenRecktangularWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GasIndexProvider()) { entry in
            LockscreenRectangularView(entry: entry)
        }
        .configurationDisplayName("Live Gas Price")
        .description("Updates every 15 minutes")
        .supportedFamilies([.accessoryRectangular, .systemSmall])
    }
}

struct LockscreenRecktangularWidget_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            LockscreenRectangularView(
                entry: GasIndexEntry(
                    date: Date(),
                    gasDataEntity: GasDataEntity(from: [], with: []),
                    gasLevel: GasLevel(
                        currentStats: CurrentStats.placeholder(),
                        currentGas: 298
                    ),
                    actions: [
                        ActionEntity(rawAction: Action(name: "USDT Transfer", groupName: "Ethereum", key: "Key", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
                        ActionEntity(rawAction: Action(name: "ETH Transfer", groupName: "Ethereum", key: "Key2", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
                        ActionEntity(rawAction: Action(name: "SCROLL", groupName: "NativeBridges", key: "Key3", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
                        ActionEntity(rawAction: Action(name: "Native Bridges", groupName: "NativeBridges", key: "Key3.5", limit: 300000), gasEntries: [], priceEntries: [], isPinned: false),
                        ActionEntity(rawAction: Action(name: "USDT Transfer", groupName: "Ethereum", key: "Key123", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
                        ActionEntity(rawAction: Action(name: "ETH Transfer", groupName: "Ethereum", key: "Key2$32", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
                        ActionEntity(rawAction: Action(name: "SCROLL", groupName: "NativeBridges", key: "Key3432", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true),
                        ActionEntity(rawAction: Action(name: "Native Bridges", groupName: "NativeBridges", key: "Key3.15", limit: 300000), gasEntries: [], priceEntries: [], isPinned: false),
                        ActionEntity(rawAction: Action(name: "STARKNET", groupName: "Native Bridges", key: "Key432", limit: 300000), gasEntries: [], priceEntries: [], isPinned: true)
                    ]
                )
            )
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
