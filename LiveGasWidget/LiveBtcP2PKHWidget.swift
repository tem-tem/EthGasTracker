//
//  LiveBtcRateWidget.swift
//  EthGasTracker
//
//  Created by Tem on 2/29/24.
//

import WidgetKit
import SwiftUI

struct LiveBtcP2PKHWidgetView: View {
    var entry: GasIndexEntry
    
    @AppStorage("subbed", store: UserDefaults(suiteName: "group.TA.EthGas")) var subbed: Bool = false
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var rate: Double {
        Double(entry.btcDataEntity.rate)
    }
    
    var p2pkh: Double {
        calculateTransactionCost(transactionSizeInVb: 226, feeRateInSatPerVb: Int(rate), bitcoinPriceInFiat: entry.btcDataEntity.price)
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
            if (entry.isPlaceholder || subbed) {
                Spacer()
                PriceNumberView(value: p2pkh)
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.4)
                    .foregroundStyle(
                        Color(.orange).gradient
                            .shadow(.inner(color: .white.opacity(0.5), radius: 2, x: 0, y: 0))
                    )
                Spacer()
    //
                Text("P2PKH")
                    .font(.caption)
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.headline)
                    Text("Tap to unlock")
                        .font(.caption)
                    Spacer()
                }
                .widgetURL(URL(string: "widget://unlock")!)
            }
        }
        .widgetBackground(
            LinearGradient(
                gradient: Gradient(
                    colors: [Color(.orange).opacity(0.3), Color(.orange).opacity(0)]
                ),
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
    
//    MARK: - WatchOS Corner
    var corner: some View {
        HStack {
            if entry.isPlaceholder || subbed {
                PriceNumberView(value: p2pkh)
            } else {
                Image(systemName: "sparkles")
                    .widgetURL(URL(string: "widget://unlock")!)
            }
        }
        .font(.headline)
//           .font(.system(size: 20))
//           .foregroundColor(entry.gasLevel.color)
           .widgetLabel {
               Text("P2PKH")
           }
        #if os(watchOS)
           .widgetCurvesContent()
        #endif
    }

//    MARK: - Lockscreen Circular
    var lockscreenCircular: some View {
        VStack {
            if entry.isPlaceholder || subbed {
                PriceNumberView(value: p2pkh)
                    .bold()
                    .font(.headline)
                    .minimumScaleFactor(0.5)
                Text("P2PKH")
                    .font(.caption)
            } else {
                Image(systemName: "sparkles")
                    .widgetURL(URL(string: "widget://unlock")!)
            }
        }
        .conditionalContainerBackground()
    }
    
//    MARK: - Lockscreen Inline
    var lockscreenInline: some View {
        HStack {
            if entry.isPlaceholder || subbed {
                PriceNumberView(value: p2pkh)
                Text(" P2PKH")
                    .font(.caption)
            } else {
                Image(systemName: "sparkles")
                .widgetURL(URL(string: "widget://unlock")!)
            }
        }
        .conditionalContainerBackground()
    }
    
//    MARK: -Lockscreen Rectangular
    var lockscreenRectangular: some View {
        HStack(alignment: .top) {
                if entry.isPlaceholder || subbed {
                    Image(systemName: "bitcoinsign.circle")
                        .font(.system(size: 20))
                    VStack {
                        PriceNumberView(value: p2pkh)
                            .bold()
                        Text("P2PKH")
                            .font(.caption)
                    }
                    Spacer()
                } else {
                    VStack {
                        Image(systemName: "sparkles")
                        Text("Tap to unlock")
                    }
                    .widgetURL(URL(string: "widget://unlock")!)
                }
        }
        .font(.system(.largeTitle, design: .rounded))
        .minimumScaleFactor(0.1)
        .lineLimit(1)
        .conditionalContainerBackground()
    }
    
}

struct LiveBtcRateP2PKHWidget: Widget {
    let kind: String = "LiveBtcP2PKHWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GasIndexProvider()) { entry in
            LiveBtcP2PKHWidgetView(entry: entry)
        }
        .configurationDisplayName("BTC P2PKH Transaction Fee")
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

struct LiveBtcP2PKHWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LiveBtcP2PKHWidgetView(entry: GasIndexEntry.placeholder)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
        }
    }
}
