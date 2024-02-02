//
//  EthGasWidget.swift
//  EthGasWidget
//
//  Created by Tem on 6/15/23.
//

import WidgetKit
import SwiftUI

struct WidgetsFamilyView : View {
    var entry: GasIndexEntry  // Change the type here
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            lockscreenRectangular
        case .accessoryInline:
            lockscreenInline
        case .accessoryCircular:
            lockscreenCircular
        case .systemLarge:
            large
        case .systemMedium:
            medium
        case .systemSmall:
            small
        default:
            Text("Unsupported widget family")
                .conditionalContainerBackground()
        }
    }
    
    var large: some View {
        VStack {
            VStack {
//                Spacer()
                Text(String(format: "%.f", entry.gasLevel.currentGas))
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(
                        entry.gasLevel.color.gradient
                            .shadow(.inner(color: .white.opacity(0.5), radius: 2, x: 0, y: 0))
                    )
                
                Text(entry.gasLevel.label)
                    .font(.caption)
                GasScaleDots(gasLevel: entry.gasLevel)
            }
            Divider()
            
            ActionsBlockDenseView(actions: entry.actions, columns: 2, amount: 8)
                .frame(maxWidth: .infinity)
        }
        .widgetBackground(Color(.systemBackground))
        .widgetBackground(
            LinearGradient(
                gradient: Gradient(
                    colors: [entry.gasLevel.color.opacity(0.3), entry.gasLevel.color.opacity(0)]
                ),
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
    
//    MARK: - Medium
    var medium: some View {
        HStack {
            VStack {
                Spacer()
                Text(String(format: "%.f", entry.gasLevel.currentGas))
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(
                        entry.gasLevel.color.gradient
                            .shadow(.inner(color: .white.opacity(0.5), radius: 2, x: 0, y: 0))
                    )
                    .frame(maxWidth: 90)
                Spacer()
                
                Text(entry.gasLevel.label)
                    .font(.caption)
                GasScaleDots(gasLevel: entry.gasLevel)
            }
            Divider()
            
            ActionsBlockDenseView(actions: entry.actions, columns: 2, amount: 4)
                .frame(maxWidth: .infinity)
        }
        .widgetBackground(Color(.systemBackground))
        .widgetBackground(
            LinearGradient(
                gradient: Gradient(
                    colors: [entry.gasLevel.color.opacity(0.3), entry.gasLevel.color.opacity(0)]
                ),
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
    
//    MARK: - Small
    var small: some View {
        VStack {
            Spacer()
            Text(String(format: "%.f", entry.gasLevel.currentGas))
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.7)
                .foregroundStyle(
                    entry.gasLevel.color.gradient
                        .shadow(.inner(color: .white.opacity(0.5), radius: 2, x: 0, y: 0))
                )
            Spacer()
            
            Text(entry.gasLevel.label)
                .font(.caption)
            GasScaleDots(gasLevel: entry.gasLevel)
        }
        .widgetBackground(Color(.systemBackground))
        .widgetBackground(
            LinearGradient(
                gradient: Gradient(
                    colors: [entry.gasLevel.color.opacity(0.3), entry.gasLevel.color.opacity(0)]
                ),
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
    
//    MARK: - Lockscreen Circular
    var lockscreenCircular: some View {
        VStack {
//            Image(systemName: "flame")
//                .font(.caption)
//            Text(String(format: "%.f", entry.gasLevel.currentGas))
//                .bold()
            Gauge(
                value: entry.gasLevel.currentGas,
                in: entry.gasLevel.currentStats.min...entry.gasLevel.currentStats.max
            ) {
                Image(systemName: "flame")
            } currentValueLabel: {
                Text(String(format: "%.f", entry.gasLevel.currentGas))
                    .bold()
            }
            .gaugeStyle(.accessoryCircular)
        }
        .conditionalContainerBackground()
    }
    
//    MARK: - Lockscreen Inline
    var lockscreenInline: some View {
        HStack {
            Image(systemName: "flame")
            Text(String(format: "%.f", entry.gasLevel.currentGas))
                .bold()
        }
        .conditionalContainerBackground()
    }
    
//    MARK: -Lockscreen Rectangular
    var lockscreenRectangular: some View {
        HStack(alignment: .center) {
            VStack {
                HStack(alignment: .center) {
                    Image(systemName: "flame")
                        .font(.system(size: 20))
                    Text(String(format: "%.f", entry.gasLevel.currentGas))
                        .bold()
                }
//                HStack {
//                    GasScaleDots(gasLevel: entry.gasLevel)
//                }
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


struct LiveGasWidget: Widget {
    let kind: String = "LiveGasWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GasIndexProvider()) { entry in
            WidgetsFamilyView(entry: entry)
        }
        .configurationDisplayName("Live Gas Price")
        .description("Updates every 15 minutes")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .accessoryCircular, .])
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetsFamilyView(
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

extension View {
    @ViewBuilder
    func conditionalContainerBackground() -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(.clear, for: .widget)
        } else {
            self // Unmodified for iOS versions below 17.0
        }
    }
}
