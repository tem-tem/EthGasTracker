//
//  LiveBtcRateWidget.swift
//  EthGasTracker
//
//  Created by Tem on 2/29/24.
//

import WidgetKit
import SwiftUI

struct LiveBtcRateWidgetView: View {
    var entry: GasIndexEntry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var rate: Double {
        Double(entry.btcDataEntity.rate)
    }
    
    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            lockscreenRectangular
        case .accessoryInline:
            lockscreenInline
        case .accessoryCircular:
            lockscreenCircular
        case .accessoryCorner:
            corner
//        case .systemLarge:
//            large
//        case .systemMedium:
//            medium
        case .systemSmall:
            small
        default:
            Text("Unsupported widget family")
                .conditionalContainerBackground()
        }
    }
    
//    MARK: - Small
    var small: some View {
        VStack {
            Spacer()
            Text(String(format: "%.f", rate))
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.7)
                .foregroundStyle(
                    Color(.orange).gradient
                        .shadow(.inner(color: .white.opacity(0.5), radius: 2, x: 0, y: 0))
                )
            Spacer()
            
            Text("sat/vB")
                .font(.caption)
        }
        .widgetBackground(
            LinearGradient(
                gradient: Gradient(
                    colors: [Color(.orange).opacity(0.3), Color(.purple).opacity(0)]
                ),
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
    
//    MARK: - WatchOS Corner
    var corner: some View {
        HStack {
            Text("\(String(format: "%.f", rate))")
        }
        .font(.headline)
//           .font(.system(size: 20))
//           .foregroundColor(entry.gasLevel.color)
           .widgetLabel {
               Text("sat/vB")
           }
        #if os(watchOS)
           .widgetCurvesContent()
        #endif
    }

//    MARK: - Lockscreen Circular
    var lockscreenCircular: some View {
        VStack {
            Text(String(format: "%.f", rate))
                .bold()
                .font(.title)
            Text("sat/vB")
                .font(.caption)
//            Image(systemName: "bitcoinsign.circle")
        }
        .conditionalContainerBackground()
    }
    
//    MARK: - Lockscreen Inline
    var lockscreenInline: some View {
        HStack {
            Text(String(format: "%.f", rate))
                .font(.system(.body, weight: .bold))
            +
            Text(" sat/vB")
                .font(.caption)
        }
        .conditionalContainerBackground()
    }
    
//    MARK: -Lockscreen Rectangular
    var lockscreenRectangular: some View {
        HStack(alignment: .top) {
            Image(systemName: "bitcoinsign.circle")
                .font(.system(size: 20))
            VStack {
                Text(String(format: "%.f", rate))
                    .bold()
                Text("sat/vB")
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

struct LiveBtcRateWidget: Widget {
    let kind: String = "LiveBtcRateWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GasIndexProvider()) { entry in
            LiveBtcRateWidgetView(entry: entry)
        }
        .configurationDisplayName("BTC Transaction Fee Rate")
        .description("Updates every 15 minutes")
        #if os(watchOS)
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular,
            .accessoryCorner
        ])
        #else
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular,
            .systemSmall
        ])
        #endif
    }
}

struct LiveBtcRateWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LiveBtcRateWidgetView(entry: GasIndexEntry.placeholder)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
        }
    }
}
