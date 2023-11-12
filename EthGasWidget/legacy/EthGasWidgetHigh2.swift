//
//  EthGasWidget.swift
//  EthGasWidget
//
//  Created by Tem on 5/15/23.
//

import WidgetKit
import SwiftUI
import Charts

// view
struct EthGasWidgetHigh2EntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HighChart(
                    gasList: entry.gasList,
                    min: entry.highMin,
                    max: entry.highMax
                )
                .frame(height: 80)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .padding(.trailing)
                .padding(.top)
                .padding(.bottom)
                .opacity(0.25)
            }
            
            HStack {
                VStack (alignment: .leading) {
                    HStack {
                        Text("High Gas")
                        Spacer()
                        Image("star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                    }
                    Spacer()
                    Text(entry.gasList.first?.FastGasPrice ?? "00")
                        .font(.system(size: 70, design: .rounded)).bold()
                        .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                        .lineLimit(1)
                        .foregroundStyle(
                            Color("high").gradient
                                .shadow(.inner(color: Color("highLight").opacity(1), radius: 4, x: 0, y: 0))
                        )
                        .shadow(color: Color(.systemBackground), radius: 5)
                    
                    Text(Date(timeIntervalSince1970: TimeInterval(entry.gasList.first?.timestamp ?? 0)), style: .relative)
                        .font(.caption2)
                    + Text(" ago")
                        .font(.caption2)
                }
            }
            .padding()
        }
    }
}

struct EthGasWidgetHigh2: Widget {
    let kind: String = "EthGasWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EthGasWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("High Gas Price")
//        .description("A number for the average gas price.")
        .supportedFamilies([.systemSmall])
    }
}

struct EthGasWidgetHigh2_Previews: PreviewProvider {
    static var previews: some View {
        EthGasWidgetHigh2EntryView(
            entry: GasListEntry(
                date: Date(),
                gasList: [
                    GasData(LastBlock: "0", SafeGasPrice: "10", ProposeGasPrice: "9", FastGasPrice: "12", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 2),
                    GasData(LastBlock: "0", SafeGasPrice: "10", ProposeGasPrice: "11", FastGasPrice: "12", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 1),
                    GasData(LastBlock: "0", SafeGasPrice: "10", ProposeGasPrice: "10", FastGasPrice: "12", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 0),
                ],
                avgMin: 9.0,
                avgMax: 11.0,
                highMin: 12.0,
                highMax: 12.0,
                lowMin: 10,
                lowMax: 10
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
