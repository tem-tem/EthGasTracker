//
//  BtcPriceWidgetFamilyView.swift
//  EthGasTracker
//
//  Created by Tem on 11/15/25.
//


//
//  BtcPriceWidget.swift
//  EthGasWidget
//
//  Created by Tem on 11/15/25.
//

import WidgetKit
import SwiftUI

// MARK: - Main View
struct BtcPriceWidgetFamilyView : View {
    var entry: GasIndexEntry // Using the existing entry from GasIndexProvider
    @Environment(\.widgetFamily) var widgetFamily
    
    // NOTE: This view assumes `entry` has property:
    // var btcDataEntity: BtcDataEntity
    
    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            lockscreenRectangularPriceView
        case .accessoryInline:
            lockscreenInlinePriceView
        case .accessoryCircular:
            lockscreenCircularPriceView
        case .accessoryCorner:
            cornerPriceView
        case .systemLarge:
            largePriceView
        case .systemMedium:
            mediumPriceView
        case .systemSmall:
            smallPriceView
        default:
            Text("Unsupported widget family")
                .conditionalContainerBackground()
        }
    }
    
    // MARK: - System Views
    
    /// Small system widget view
    var smallPriceView: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "bitcoinsign")
                    .foregroundColor(Color.orange.opacity(0.8))
                Spacer()
                Text(entry.date, style: .time)
            }
            .foregroundStyle(.secondary)
            Spacer()
            // BTC Price
//            Text("BTC")
//                .font(.caption.bold())
//                .foregroundColor(Color.orange.opacity(0.8))
            Text(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .fontWeight(.semibold)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundStyle(Color.orange.gradient)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetBackground(
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    /// Medium system widget view
    var mediumPriceView: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: "bitcoinsign")
                    .foregroundColor(Color.orange.opacity(0.8))
                Spacer()
                Text(entry.date, style: .time)
            }
            .foregroundStyle(.secondary)
            Spacer()
            // BTC Column
            Text(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundStyle(Color.orange.gradient)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetBackground(
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.clear],
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
    
    /// Large system widget view
    var largePriceView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "bitcoinsign")
                    .foregroundColor(Color.orange.opacity(0.8))
                Spacer()
                Text(entry.date, style: .time)
            }
            .foregroundStyle(.secondary)
            Spacer()
            // BTC Block
            VStack(alignment: .leading, spacing: 5) {
//                Text("BTC")
//                    .font(.title2)
//                    .foregroundColor(Color.orange.opacity(0.8))
                Text(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(Color.orange.gradient)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetBackground(
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.clear],
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
    
    // MARK: - Accessory (Lockscreen) Views
    
    /// Rectangular lockscreen widget
    var lockscreenRectangularPriceView: some View {
        VStack(alignment: .leading) {
            Image(systemName: "bitcoinsign")
                .font(.caption)
            Text(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(.system(size: 28, design: .rounded))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .conditionalContainerBackground()
    }

    /// Circular lockscreen widget
    var lockscreenCircularPriceView: some View {
        VStack {
            Image(systemName: "bitcoinsign")
                .font(.caption)
            Text(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0))) // Changed from ethPrice
                .font(.system(size: 16))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .conditionalContainerBackground()
    }

    /// Inline lockscreen widget
    var lockscreenInlinePriceView: some View {
        HStack(spacing: 4) {
            Image(systemName: "bitcoinsign")
            Text("\(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))") // Removed ETH
        }
        .conditionalContainerBackground()
    }
    
    /// Watch Corner widget
    var cornerPriceView: some View {
        HStack(spacing: 2) {
            Image(systemName: "bitcoinsign")
            Text(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))
        }
        .font(.system(size: 12, weight: .bold))
        .minimumScaleFactor(0.8)
        .lineLimit(1)
         #if os(watchOS)
        .widgetCurvesContent()
         #endif
    }
}


// MARK: - Widget Definition
struct BtcPriceWidget: Widget {
    let kind: String = "BtcPriceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: GasIndexProvider() // Use the existing provider
        ) { entry in
            BtcPriceWidgetFamilyView(entry: entry) // Use the BTC-only view
        }
        .configurationDisplayName("BTC Price")
        .description("Shows the live BTC price.")
        // Copy the supportedFamilies from LiveGasWidget
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
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
        #endif
    }
}

// MARK: - Previews
struct BtcPriceWidget_Previews: PreviewProvider {
    static var previews: some View {
        let placeholderEntry = GasIndexEntry.placeholder
        
        Group {
            BtcPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")
            
            BtcPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")
            
            BtcPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")
            
            BtcPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Rectangular")
            
            BtcPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Circular")
            
            BtcPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Inline")
        }
    }
}
