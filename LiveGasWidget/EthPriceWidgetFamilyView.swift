//
//  EthPriceWidgetFamilyView.swift
//  EthGasTracker
//
//  Created by Tem on 11/15/25.
//


//
//  EthPriceWidget.swift
//  EthGasWidget
//
//  Created by Tem on 11/15/25.
//

import WidgetKit
import SwiftUI

// MARK: - Main View
struct EthPriceWidgetFamilyView : View {
    var entry: GasIndexEntry // Using the existing entry from GasIndexProvider
    @Environment(\.widgetFamily) var widgetFamily
    
    // NOTE: This view assumes `entry` has property:
    // var ethPrice: Double
    
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
                Image("eth-symbol")
                Text("ETH")
                Spacer()
                Text(entry.date, style: .time)
            }
            .foregroundStyle(.secondary)
            .font(.caption)
            Spacer()
            // ETH Price
//            Text("ETH")
//                .font(.caption.bold())
//                .foregroundColor(Color.blue.opacity(0.8))
            Text(entry.ethPrice, format: .currency(code: "USD"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .fontWeight(.semibold)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundStyle(Color.blue.gradient)
//            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.horizontal)
        .widgetBackground(
            LinearGradient(
                colors: [Color.blue.opacity(0.15), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    /// Medium system widget view
    var mediumPriceView: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image("eth-symbol")
                Text("ETH")
                Spacer()
                Text(entry.date, style: .time)
            }
            .foregroundStyle(.secondary)
            Spacer()
            // ETH Column
//            Text("ETH")
//                .font(.headline)
//                .foregroundColor(Color.blue.opacity(0.8))
            Text(entry.ethPrice, format: .currency(code: "USD"))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundStyle(Color.blue.gradient)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding()
        .widgetBackground(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    /// Large system widget view
    var largePriceView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image("eth-symbol")
                Text("ETH")
                Spacer()
                Text(entry.date, style: .time)
            }
            .foregroundStyle(.secondary)
            Spacer()
            // ETH Block
            VStack(alignment: .leading, spacing: 5) {
                Text(entry.ethPrice, format: .currency(code: "USD"))
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(Color.blue.gradient)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetBackground(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.clear],
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
    
    // MARK: - Accessory (Lockscreen) Views
    
    /// Rectangular lockscreen widget
    var lockscreenRectangularPriceView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .center, spacing: 2) {
                Image("eth-symbol")
                Text("ETH")
                    .font(.caption)
            }
            Text(entry.ethPrice, format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(.system(size: 48, design: .rounded))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .conditionalContainerBackground()
    }

    /// Circular lockscreen widget
    var lockscreenCircularPriceView: some View {
        VStack {
            Image("eth-symbol")
                .font(.caption)
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
            Image("eth-symbol")
            Text("ETH \(entry.ethPrice, format: .currency(code: "USD").precision(.fractionLength(0)))")
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
struct EthPriceWidget: Widget {
    let kind: String = "EthPriceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: GasIndexProvider() // Use the existing provider
        ) { entry in
            EthPriceWidgetFamilyView(entry: entry) // Use the ETH-only view
        }
        .configurationDisplayName("ETH Price")
        .description("Shows the live ETH price.")
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
struct EthPriceWidget_Previews: PreviewProvider {
    static var previews: some View {
        let placeholderEntry = GasIndexEntry.placeholder
        
        Group {
            EthPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")
            
            EthPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")
            
            EthPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large")
            
            EthPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Rectangular")
            
            EthPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Circular")
            
            EthPriceWidgetFamilyView(entry: placeholderEntry)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Inline")
        }
    }
}
#endif
