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
//            VStack {
////                Spacer(minLength: 50)
//                Spacer()
//                HighChart(
//                    gasList: entry.gasList,
//                    min: entry.highMin,
//                    max: entry.highMax
//                )
//                .frame(height: 25)
//                .chartXAxis(.hidden)
//                .chartYAxis(.hidden)
//                .padding(.trailing)
////                .padding(.top)
////                .padding(.bottom)
////                .padding(.bottom, 5)
//                .opacity(0.5)
//                AvgChart(
//                    gasList: entry.gasList,
//                    min: entry.avgMin,
//                    max: entry.avgMax
//                )
//                .frame(height: 25)
//                .chartXAxis(.hidden)
//                .chartYAxis(.hidden)
//                .padding(.trailing)
////                .padding(.top)
////                .padding(.bottom, 5)
//                .opacity(0.5)
//                LowChart(
//                    gasList: entry.gasList,
//                    min: entry.lowMin,
//                    max: entry.lowMax
//                )
//                .frame(height: 25)
//                .chartXAxis(.hidden)
//                .chartYAxis(.hidden)
//                .padding(.trailing)
////                .padding(.top)
//                .padding(.bottom)
//                .opacity(0.5)
//
//            }
            
//            VStack {
//                HStack {
//                    Text(Date(timeIntervalSince1970: TimeInterval(entry.gasList.first?.timestamp ?? 0)), style: .relative)
//                        .font(.caption2)
//                    + Text(" ago")
//                        .font(.caption2)
//                    Spacer()
//                    Image("star")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 10, height: 10)
//                }
//                Spacer()
//            }
//            .padding()
            
            HStack {
                VStack (alignment: .leading) {
                    HStack(alignment: .center) {
                        Image(systemName: "flame").font(.system(size: 25))
                        Text("\(entry.gasList.first?.ProposeGasPrice ?? "00")")
                            .bold()
                        Spacer()
                        VStack {
                            Text("H.\(entry.gasList.first?.FastGasPrice ?? "00")")
                                .font(.body)
                            Text("L.\(entry.gasList.first?.SafeGasPrice ?? "00")")
                                .font(.body)
                        }
                        
                        
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
    let kind: String = "EthGasLockScreenWidget"

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
                    GasData(LastBlock: "0", SafeGasPrice: "839", ProposeGasPrice: "150", FastGasPrice: "132", suggestBaseFee: "10", gasUsedRatio: "104", timestamp: 2),
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
