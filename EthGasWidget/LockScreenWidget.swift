//
//  EthGasWidget.swift
//  EthGasWidget
//
//  Created by Tem on 6/15/23.
//

import WidgetKit
import SwiftUI

struct LockScreenEntryView : View {
    var entry: GasIndexEntry  // Change the type here
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            lockscreenWidget
        case .systemSmall:
            homeScreenSmall
        default:
            Text("Unsupported widget family")
        }
    }
    
    var homeScreenSmall: some View {
        VStack {
            HStack {
                GasScaleDots(gasLevel: entry.gasLevel)
                Spacer()
                Text(String(format: "%.f", entry.gasLevel.currentGas ?? 0))
//                    Text("999")
                    .font(.system(size: 100, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(
                        entry.gasLevel.color.gradient
                            .shadow(.inner(color: .white.opacity(0.5), radius: 2, x: 0, y: 0))
                    )
                Spacer()
                GasScaleDots(gasLevel: entry.gasLevel).opacity(0)
            }
                .padding(.bottom)
            Text(entry.gasLevel.label)
                .font(.caption)
        }
//        .overlay(
//            Rectangle()
//                .background(
//                    LinearGradient(
//                        gradient: Gradient(
//                            colors: [entry.gasLevel.color.opacity(0.5), entry.gasLevel.color.opacity(0)]
//                        ),
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//            )
//        )
        .widgetBackground(Color.black)
    }
    
    var lockscreenWidget: some View {
        HStack(alignment: .center) {
            VStack {
                HStack(alignment: .center) {
                    Image(systemName: "flame")
                        .font(.system(size: 20))
                    Text(String(format: "%.f", entry.gasLevel.currentGas ?? 0))
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
        .widgetBackground(Color.black)
    }
}


struct LockScreenWidget: Widget {
    let kind: String = "EthGasLockScreenWidgetLarge"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GasIndexProvider()) { entry in
            LockScreenEntryView(entry: entry)
        }
        .configurationDisplayName("Gas Price")
        .description("Shows gas price")
        .supportedFamilies([.accessoryRectangular, .systemSmall])
    }
}

//struct LockScreenWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        LockScreenEntryView(
//            entry: GasListEntry(
//                date: Date(),
//                gasList: [
//                    GasData(LastBlock: "0", SafeGasPrice: "83", ProposeGasPrice: "15", FastGasPrice: "13", suggestBaseFee: "10", gasUsedRatio: "104", timestamp: 2),
//                    GasData(LastBlock: "0", SafeGasPrice: "7", ProposeGasPrice: "11", FastGasPrice: "13", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 1),
//                    GasData(LastBlock: "0", SafeGasPrice: "9", ProposeGasPrice: "10", FastGasPrice: "14", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 0),
//                ],
//                avgMin: 9.0,
//                avgMax: 11.0,
//                highMin: 12.0,
//                highMax: 14.0,
//                lowMin: 7,
//                lowMax: 9
//            )
//        )
//        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//    }
//}
