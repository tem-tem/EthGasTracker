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
struct EthGasWidgetAllEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            VStack {
//                Spacer(minLength: 50)
                Spacer()
                HighChart(
                    gasList: entry.gasList,
                    min: entry.highMin,
                    max: entry.highMax
                )
                .frame(height: 25)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .padding(.trailing)
//                .padding(.top)
//                .padding(.bottom)
//                .padding(.bottom, 5)
                .opacity(0.5)
                AvgChart(
                    gasList: entry.gasList,
                    min: entry.avgMin,
                    max: entry.avgMax
                )
                .frame(height: 25)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .padding(.trailing)
//                .padding(.top)
//                .padding(.bottom, 5)
                .opacity(0.5)
                LowChart(
                    gasList: entry.gasList,
                    min: entry.lowMin,
                    max: entry.lowMax
                )
                .frame(height: 25)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .padding(.trailing)
//                .padding(.top)
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
//                    Image("star")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 10, height: 10)
                }
                Spacer()
            }
            .padding()
            
            HStack {
                VStack (alignment: .leading) {
                    Text(entry.gasList.first?.FastGasPrice ?? "00")
                        .font(.system(size: 40, design: .rounded)).bold()
                        .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                        .lineLimit(1)
                        .foregroundStyle(
                            Color("high").gradient
                                .shadow(.inner(color: Color("highLight").opacity(1), radius: 4, x: 0, y: 0))
                        )
                        .shadow(color: Color(.systemBackground), radius: 3)
                        .shadow(color: Color(.systemBackground), radius: 5)
                        .shadow(color: Color(.systemBackground), radius: 10)
                
                    Text(entry.gasList.first?.ProposeGasPrice ?? "00")
                        .font(.system(size: 40, design: .rounded)).bold()
                        .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                        .lineLimit(1)
                        .foregroundStyle(
                            Color("avg").gradient
                                .shadow(.inner(color: Color("avgLight").opacity(1), radius: 4, x: 0, y: 0))
                        )
                        .shadow(color: Color(.systemBackground), radius: 3)
                        .shadow(color: Color(.systemBackground), radius: 5)
                        .shadow(color: Color(.systemBackground), radius: 10)
                    
                    Text(entry.gasList.first?.SafeGasPrice ?? "00")
                        .font(.system(size: 40, design: .rounded)).bold()
                        .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                        .lineLimit(1)
                        .foregroundStyle(
                            Color("low").gradient
                                .shadow(.inner(color: Color("lowLight").opacity(1), radius: 4, x: 0, y: 0))
                        )
                        .shadow(color: Color(.systemBackground), radius: 3)
                        .shadow(color: Color(.systemBackground), radius: 5)
                        .shadow(color: Color(.systemBackground), radius: 10)
                }
                Spacer()
            }.padding()
                .padding(.top)
            .padding(.top)
        }
    }
}

struct EthGasWidgetAll: Widget {
    let kind: String = "EthGasWidgetAll"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EthGasWidgetAllEntryView(entry: entry)
        }
        .configurationDisplayName("Three Graphs")
//        .description("Average, high, and low fees.")
        .supportedFamilies([.systemSmall])
    }
}

struct EthGasWidgetAll_Previews: PreviewProvider {
    static var previews: some View {
        EthGasWidgetAllEntryView(
            entry: GasListEntry(
                date: Date(),
                gasList: [
                    GasData(LastBlock: "0", SafeGasPrice: "8", ProposeGasPrice: "9", FastGasPrice: "12", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 2),
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
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
