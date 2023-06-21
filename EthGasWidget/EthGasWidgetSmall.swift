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
struct EthGasWidgetSmallEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            VStack {
                AvgChart(
                    gasList: entry.gasList,
                    min: entry.avgMin,
                    max: entry.avgMax
                )
                .frame(height: 80)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .padding(.trailing)
                .padding(.top)
                .padding(.bottom)
                .opacity(0.4)
                Spacer()
            }
            VStack {
                HStack {
                    Text(entry.gasList.first?.ProposeGasPrice ?? "00")
                        .font(.system(size: 70, design: .rounded)).bold()
                        .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                        .lineLimit(1)
                        .foregroundStyle(
                            Color("avg").gradient
                                .shadow(.inner(color: Color("avgLight").opacity(1), radius: 4, x: 0, y: 0))
                        )
                        .shadow(color: Color(.systemBackground), radius: 5)
                    Spacer()
                }
                .padding()
                Spacer()
            }
            
            VStack (alignment: .leading) {
                Spacer()
                HStack(alignment: .center) {
                    Text("H.\(entry.gasList.first?.FastGasPrice ?? "00")")
                        .bold()
                    Image(systemName: "line.diagonal")
                        .foregroundColor(.secondary)
                    Text("L.\(entry.gasList.first?.SafeGasPrice ?? "00")")
                        .bold()
                }
                Text(Date(timeIntervalSince1970: TimeInterval(entry.gasList.first?.timestamp ?? 0)), style: .relative)
                    .font(.caption2)
                + Text(" ago")
                    .font(.caption2)
            }
            .padding()
        }
    }
}

struct EthGasWidgetSmall: Widget {
    let kind: String = "EthGasWidget.small"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EthGasWidgetSmallEntryView(entry: entry)
        }
        .configurationDisplayName("Average")
        .description("Includes high and low.")
        .supportedFamilies([.systemSmall])
    }
}

struct EthGasWidgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        EthGasWidgetSmallEntryView(
            entry: GasListEntry(
                date: Date(),
                gasList: [
                    GasData(LastBlock: "0", SafeGasPrice: "10", ProposeGasPrice: "9", FastGasPrice: "12", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 2),
                    GasData(LastBlock: "0", SafeGasPrice: "7", ProposeGasPrice: "11", FastGasPrice: "13", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 1),
                    GasData(LastBlock: "0", SafeGasPrice: "8", ProposeGasPrice: "10", FastGasPrice: "10", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 0),
                ],
                avgMin: 9.0,
                avgMax: 11.0,
                highMin: 10.0,
                highMax: 13.0,
                lowMin: 7,
                lowMax: 10
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
