//
//  EthGasWidget.swift
//  EthGasWidget
//
//  Created by Tem on 6/15/23.
//

import WidgetKit
import SwiftUI
import Charts

struct LockScreenEntryView : View {
    var entry: GasIndexEntry  // Change the type here

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "flame")
                .font(.system(size: 30))
            
            Text(String(format: "%.f", entry.gasIndexEntries.first?.normal ?? 0))
                .bold()
            Spacer()
        }
        .font(.system(.largeTitle, design: .rounded))
        .minimumScaleFactor(0.1)
        .lineLimit(1)
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
        .supportedFamilies([.accessoryRectangular])
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
