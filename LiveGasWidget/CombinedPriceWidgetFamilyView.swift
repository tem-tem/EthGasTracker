//
//  CombinedPriceWidgetFamilyView.swift
//  EthGasTracker
//
//  Created by Tem on 11/15/25.
//


//
//  CombinedPriceWidget.swift
//  EthGasWidget
//
//  Created by Tem on 11/15/25.
//

import WidgetKit
import SwiftUI

// MARK: - Main View
struct CombinedPriceWidgetFamilyView : View {
    var entry: GasIndexEntry // Using the existing entry from GasIndexProvider
    @Environment(\.widgetFamily) var widgetFamily
    
    // NOTE: This view assumes `entry` has properties:
    // var ethPrice: Double
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
                .conditionalContainerBackground() // Uses your existing extension
        }
    }
    
    // MARK: - System Views
    
    /// Small system widget view
    var smallPriceView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
//                Image(systemName: "flame")
                Spacer()
                Text(entry.date, style: .time)
//                Spacer()
            }
            .foregroundStyle(.secondary)
            .font(.caption)
            Spacer()
            // ETH Price
            VStack(alignment: .leading) {
                HStack {
                    Image("eth-symbol")
                    Text("ETH")
                    Spacer()
                }
                .foregroundStyle(.secondary)
                .font(.caption)
                Text(entry.ethPrice, format: .currency(code: "USD"))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(Color.blue.gradient)
            }
            Divider()
            // BTC Price
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "bitcoinsign.circle.fill")
                    Text("BTC")
                }
                .font(.caption)
                .foregroundColor(Color.orange.opacity(0.8))
                Text(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(Color.orange.gradient)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetBackground( // Uses your existing extension
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    /// Medium system widget view
    var mediumPriceView: some View {
        VStack(spacing: 15) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(entry.date, style: .time)
                            .foregroundColor(.secondary)
                            .font(.caption)
//                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Image("eth-symbol")
                            .frame(width: 20, height: 20)
                        Text("ETH")
                            .font(.headline)
                            .foregroundColor(.secondary)
//                        Spacer()
                    }
                }
                Spacer()
                Text(entry.ethPrice, format: .currency(code: "USD"))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(Color.blue.gradient)
            }
            Divider()
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.orange)
                            .frame(width: 20, height: 20)
                        Text("BTC")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(Color.orange.gradient)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .widgetBackground(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.orange.opacity(0.05)],
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
    
    /// Large system widget view
    var largePriceView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(entry.date, style: .time)
                    .foregroundColor(.secondary)
                    .font(.caption)
//                        Spacer()
            }
            Spacer()
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        Image("eth-symbol")
                            .frame(width: 20, height: 20)
                        Text("ETH")
                            .font(.headline)
                            .foregroundColor(.secondary)
//                        Spacer()
                    }
                }
                Text(entry.ethPrice, format: .currency(code: "USD"))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(Color.blue.gradient)
            }
            Divider()
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.orange)
                            .frame(width: 20, height: 20)
                        Text("BTC")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                Text(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(Color.orange.gradient)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetBackground(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.orange.opacity(0.1), Color.clear],
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
    
    // MARK: - Accessory (Lockscreen) Views
    
    /// Rectangular lockscreen widget
    var lockscreenRectangularPriceView: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    Image("eth-symbol")
                    Text("ETH")
                }
                .font(.caption)
                Text(entry.ethPrice, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.headline)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            Divider()
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    Image(systemName: "bitcoinsign.circle.fill")
                    Text("BTC")
                }
                .font(.caption)
                Text(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.headline)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
        }
        .conditionalContainerBackground()
    }

    /// Circular lockscreen widget
    var lockscreenCircularPriceView: some View {
        VStack {
            Text(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(.system(size: 16))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(entry.ethPrice, format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(.system(size: 16))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .conditionalContainerBackground()
    }

    /// Inline lockscreen widget
    var lockscreenInlinePriceView: some View {
        HStack(spacing: 4) {
            Text("\(entry.ethPrice, format: .currency(code: "USD").precision(.fractionLength(0))) / \(entry.btcDataEntity.price, format: .currency(code: "USD").precision(.fractionLength(0)))")
        }
        .conditionalContainerBackground()
    }
    
    /// Watch Corner widget
    var cornerPriceView: some View {
        HStack(spacing: 2) {
            Text("E") // Short for ETH
            Text(entry.ethPrice, format: .currency(code: "USD").precision(.fractionLength(0)))
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
struct CombinedPriceWidget: Widget {
    let kind: String = "CombinedPriceWidget" // Renamed from "LivePriceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            // Use the *existing* provider, as requested
            provider: GasIndexProvider()
        ) { entry in
            // Use the renamed view
            CombinedPriceWidgetFamilyView(entry: entry)
        }
        .configurationDisplayName("ETH & BTC Prices") // Renamed
        .description("Shows live ETH and BTC prices together.") // Renamed
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

#if os(iOS)
// MARK: - Previews
struct CombinedPriceWidget_Previews: PreviewProvider { // Renamed
    static var previews: some View {
        // Use the placeholder from the *existing* entry
        let placeholderEntry = GasIndexEntry.placeholder
        
        Group {
            CombinedPriceWidgetFamilyView(entry: placeholderEntry) // Renamed
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")
            
            CombinedPriceWidgetFamilyView(entry: placeholderEntry) // Renamed
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")
            
            CombinedPriceWidgetFamilyView(entry: placeholderEntry) // Renamed
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")
            
            CombinedPriceWidgetFamilyView(entry: placeholderEntry) // Renamed
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Rectangular")
            
            CombinedPriceWidgetFamilyView(entry: placeholderEntry) // Renamed
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Circular")
            
            CombinedPriceWidgetFamilyView(entry: placeholderEntry) // Renamed
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Inline")
        }
    }
}

#endif
