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
struct EthGasWidgetHighEntryView : View {
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
                .frame(height: 40)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .padding(.trailing)
                .padding(.top)
                .padding(.bottom)
                .opacity(0.5)
                
            }
            
            VStack {
                HStack {
                    Text(Date(timeIntervalSince1970: TimeInterval(entry.gasList.first?.timestamp ?? 0)), style: .relative)
                        .font(.caption2)
                    + Text(" ago")
                        .font(.caption2)
                    Spacer()
                    Image("star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                Spacer()
            }
            .padding()
            
            VStack (alignment: .center) {
                Text(entry.gasList.first?.FastGasPrice ?? "00")
                    .font(.system(size: 90, design: .rounded)).bold()
                    .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                    .lineLimit(1)
                    .foregroundStyle(
                        Color("high").gradient
                            .shadow(.inner(color: Color("highLight").opacity(1), radius: 4, x: 0, y: 0))
                    )
                    .shadow(color: Color(.systemBackground), radius: 5)
            }
            .padding(.top)
        }
    }
}

struct EthGasWidgetHigh: Widget {
    let kind: String = "EthGasWidgetHigh"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EthGasWidgetHighEntryView(entry: entry)
        }
        .configurationDisplayName("Large High")
        .supportedFamilies([.systemSmall])
    }
}

struct EthGasWidgetHigh_Previews: PreviewProvider {
    static var previews: some View {
        EthGasWidgetLowEntryView(
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
