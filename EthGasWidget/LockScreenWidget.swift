//
//  EthGasWidget.swift
//  EthGasWidget
//
//  Created by Tem on 6/15/23.
//

import WidgetKit
import SwiftUI
import Charts

// view
struct LockScreenEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            HStack {
                VStack (alignment: .leading) {
                    HStack(alignment: .center) {
                        Image(systemName: "flame").font(.system(size: 25))
                        Text("\(entry.gasList.first?.ProposeGasPrice ?? "00")")
                            .bold()
                        Spacer()
                        Divider()
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("high:")
                                    .font(.system(size: 12, design: .monospaced))
//                                Spacer()
                                Text("\(entry.gasList.first?.FastGasPrice ?? "00")").bold()
                            }.padding(.horizontal, 2)
                            HStack {
                                Text("low:")
//                                Spacer()
                                Text("\(entry.gasList.first?.SafeGasPrice ?? "00")").bold()
                            }.padding(.horizontal, 2)
                        }
//                        .background(.primary.opacity(0.1))
                        .cornerRadius(5)
                        .font(.system(size: 12, design: .monospaced))
                        
                        
                    }
                    .font(.system(size: 40, design: .rounded))
                    .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                    .lineLimit(1)
                    
                Spacer()
                Text(Date(timeIntervalSince1970: TimeInterval(entry.gasList.first?.timestamp ?? 0)), style: .relative)
                    .font(.caption)
                    + Text(" ago")
                        .font(.caption)
                }
            }
        }
    }
}

struct LockScreenWidget: Widget {
    let kind: String = "EthGasLockScreenWidgetLarge"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LockScreenEntryView(entry: entry)
        }
        .configurationDisplayName("Gas Price")
        .description("H. - High, L. - Low")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct LockScreenWidget_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenEntryView(
            entry: GasListEntry(
                date: Date(),
                gasList: [
                    GasData(LastBlock: "0", SafeGasPrice: "83", ProposeGasPrice: "15", FastGasPrice: "13", suggestBaseFee: "10", gasUsedRatio: "104", timestamp: 2),
                    GasData(LastBlock: "0", SafeGasPrice: "7", ProposeGasPrice: "11", FastGasPrice: "13", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 1),
                    GasData(LastBlock: "0", SafeGasPrice: "9", ProposeGasPrice: "10", FastGasPrice: "14", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 0),
                ],
                avgMin: 9.0,
                avgMax: 11.0,
                highMin: 12.0,
                highMax: 14.0,
                lowMin: 7,
                lowMax: 9
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
