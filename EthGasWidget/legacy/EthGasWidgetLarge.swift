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
struct EthGasWidgetLargeEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    AvgChart(
                        gasList: entry.gasList,
                        min: entry.avgMin,
                        max: entry.avgMax
                    )
                    .padding(.trailing)
                    .opacity(0.8)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(colorScheme == .dark ? .black : .white),
                                    Color(colorScheme == .dark ? .black : .white).opacity(0),
                                    Color(colorScheme == .dark ? .black : .white).opacity(0)
                                ]),
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )
                    HStack {
                        Text(entry.gasList.first?.ProposeGasPrice ?? "00")
                            .font(.system(size: 150, design: .rounded)).bold()
                            .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                            .lineLimit(1)
                            .foregroundStyle(
                                Color("avg").gradient
                                    .shadow(.inner(color: Color("avgLight").opacity(1), radius: 4, x: 0, y: 0))
                            )
                            .shadow(color: Color(.systemBackground), radius: 5)
                        Spacer()
                    }
                    .padding(.leading)
                    .padding(.bottom)
                }
                HStack {
                    ZStack {
                        LowChart(
                            gasList: entry.gasList,
                            min: entry.lowMin,
                            max: entry.lowMax
                        )
                        .frame(height: 60)
                        .padding(.trailing)
                        .opacity(0.4)
                        
                        
                        HStack {
                            Text(entry.gasList.first?.SafeGasPrice ?? "00")
                                .font(.system(size: 70, design: .rounded)).bold()
                                .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                                .lineLimit(1)
                                .foregroundStyle(
                                    Color("low").gradient
                                        .shadow(.inner(color: Color("lowLight").opacity(1), radius: 4, x: 0, y: 0))
                                )
                                .shadow(color: Color(.systemBackground), radius: 5)
                            Spacer()
                        }.padding(.leading)
                    }
                    
                    ZStack {
                        HighChart(
                            gasList: entry.gasList,
                            min: entry.highMin,
                            max: entry.highMax
                        )
                        .frame(height: 60)
                        .padding(.trailing)
                        .opacity(0.4)
                        
                        
                        HStack {
                            Text(entry.gasList.first?.FastGasPrice ?? "00")
                                .font(.system(size: 70, design: .rounded)).bold()
                                .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                                .lineLimit(1)
                                .foregroundStyle(
                                    Color("high").gradient
                                        .shadow(.inner(color: Color("highLight").opacity(1), radius: 4, x: 0, y: 0))
                                )
                                .shadow(color: Color(.systemBackground), radius: 5)
                            Spacer()
                        }.padding(.leading)
                    }
                }.padding(.bottom)
                HStack(alignment: .center) {
                    Text(Date(timeIntervalSince1970: TimeInterval(entry.gasList.first?.timestamp ?? 0)), style: .relative)
                        .font(.caption2)
                    + Text(" ago")
                        .font(.caption2)
                }.padding(.leading)
            }
            .padding(.top)
            .padding(.bottom)
        }
    }
}

struct EthGasWidgetLarge: Widget {
    let kind: String = "EthGasWidget.large"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EthGasWidgetLargeEntryView(entry: entry)
        }
        .configurationDisplayName("Full Graphs")
//        .description("A number for the average gas price.")
        .supportedFamilies([.systemLarge])
    }
}

struct EthGasWidgetLarge_Previews: PreviewProvider {
    static var previews: some View {
        EthGasWidgetLargeEntryView(
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
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
