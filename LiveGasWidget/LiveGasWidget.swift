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
            
            
            ActionsBlockDenseView(
                actions: entry.actions,
                gas: entry.gas,
                ethPrice: entry.ethPrice,
                columns: 2,
                amount: 8
            )
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
            
            ActionsBlockDenseView(
                actions: entry.actions,
                gas: entry.gas,
                ethPrice: entry.ethPrice,
                columns: 2,
                amount: 4
            )
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
            Gauge(
                value: entry.gasLevel.currentGas,
                in: entry.gasLevel.currentStats.min...entry.gasLevel.currentStats.max
            ) {
                Image(systemName: "flame")
//                Text("gwei")
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
    let kind: String = "LiveGasWidgets"
//    let provider: GasIndexProvider =

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GasIndexProvider()) { entry in
            WidgetsFamilyView(entry: entry)
        }
        .configurationDisplayName("Live Gas Price")
        .description("Updates every 15 minutes")
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular,
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetsFamilyView(entry: GasIndexEntry.placeholder)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        }
    }
}

extension View {
    @ViewBuilder
    func conditionalContainerBackground() -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(.background, for: .widget)
        } else {
            self // Unmodified for iOS versions below 17.0
        }
    }
}


extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
