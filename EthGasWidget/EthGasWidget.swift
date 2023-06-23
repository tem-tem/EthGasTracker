//
//  EthGasWidget.swift
//  EthGasWidget
//
//  Created by Tem on 5/15/23.
//

import WidgetKit
import SwiftUI
import Charts

// a data that i populate the widget with
struct GasListEntry: TimelineEntry {
    let date: Date
    let gasList: [GasData]
    let avgMin: Double
    let avgMax: Double
    let highMin: Double
    let highMax: Double
    let lowMin: Double
    let lowMax: Double
}

struct Provider: TimelineProvider {
    private let api = MyAPI()
    
    typealias Entry = GasListEntry
    private let fetcherViewModel = FetcherViewModel()
    private var gasListLoader = GasListLoader()

    func getSnapshot(in context: Context, completion: @escaping (GasListEntry) -> Void) {
       
       // Create a dispatch group to wait for the data to be fetched
       let dispatchGroup = DispatchGroup()
       
       // Enter the dispatch group
       dispatchGroup.enter()
       
       // Call fetchData in FetcherViewModel
       fetcherViewModel.fetchData()
       
       // Observe the fetcherViewModel's gasList property for changes
       fetcherViewModel.$gasList.sink { _ in
           // Once the gasList changes, leave the dispatch group
           dispatchGroup.leave()
       }
       
       // Wait for the fetchData task to complete
       dispatchGroup.notify(queue: .main) {
           // Once fetchData is complete, load the gas list from user defaults
           let gasListData = gasListLoader.loadGasDataListFromUserDefaults()
           
           let minMaxAverage = getMinMax(from: gasListData, keyPath: \.ProposeGasPrice)
           let avgMin = minMaxAverage.min ?? 9999.9
           let avgMax = minMaxAverage.max ?? 0.0
           
           let minMaxLow = getMinMax(from: gasListData, keyPath: \.SafeGasPrice)
           let lowMin = minMaxLow.min ?? 9999.9
           let lowMax = minMaxLow.max ?? 0.0
           
           let minMaxHigh = getMinMax(from: gasListData, keyPath: \.FastGasPrice)
           let highMin = minMaxHigh.min ?? 9999.9
           let highMax = minMaxHigh.max ?? 0.0
           
           let entry = GasListEntry(
                date: Date(),
                gasList: gasListData,
                avgMin: avgMin,
                avgMax: avgMax,
                highMin: highMin,
                highMax: highMax,
                lowMin: lowMin,
                lowMax: lowMax
           )
           // Call the completion handler
           completion(entry)
       }
    }
    
    // when there's no data
    func placeholder(in context: Context) -> GasListEntry {
        GasListEntry(
            date: Date(),
            gasList: [
                GasData(LastBlock: "0", SafeGasPrice: "10", ProposeGasPrice: "9", FastGasPrice: "12", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 0),
                GasData(LastBlock: "0", SafeGasPrice: "10", ProposeGasPrice: "11", FastGasPrice: "12", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 0),
                GasData(LastBlock: "0", SafeGasPrice: "10", ProposeGasPrice: "10", FastGasPrice: "12", suggestBaseFee: "10", gasUsedRatio: "10", timestamp: 0),
            ],
            avgMin: 9.0,
            avgMax: 11.0,
            highMin: 12.0,
            highMax: 12.0,
            lowMin: 10,
            lowMax: 10
        )
    }

    // show actual data (e.g. picking a widget to put on)
//    func getSnapshot(in context: Context, completion: @escaping (GasListEntry) -> Void) {
//        let entry = GasListEntry(date: Date(), gasList: [])
//            completion(entry)
//        }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // Use UserDefaults with the app group suite name
        
        api.fetchGasList { response, error in
            if let error = error {
                print("Error fetching", error)
                return
            }
            
            guard let gasListData = response?.gas_list else {
                print("Invalid response", response)
//                self?.status = .failure(NSError(domain: "Invalid response", code: 0, userInfo: nil))
                return
            }
            
            let date = Date()
            
            let minMaxAverage = getMinMax(from: gasListData, keyPath: \.ProposeGasPrice)
            let avgMin = minMaxAverage.min ?? 9999.9
            let avgMax = minMaxAverage.max ?? 0.0
            
            let minMaxLow = getMinMax(from: gasListData, keyPath: \.SafeGasPrice)
            let lowMin = minMaxLow.min ?? 9999.9
            let lowMax = minMaxLow.max ?? 0.0
            
            let minMaxHigh = getMinMax(from: gasListData, keyPath: \.FastGasPrice)
            let highMin = minMaxHigh.min ?? 9999.9
            let highMax = minMaxHigh.max ?? 0.0
            
            let entry = GasListEntry(
                 date: Date(),
                 gasList: gasListData,
                 avgMin: avgMin,
                 avgMax: avgMax,
                 highMin: highMin,
                 highMax: highMax,
                 lowMin: lowMin,
                 lowMax: lowMax
            )
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: date) ?? date
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}


// view
struct EthGasWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                AvgChart(
                    gasList: entry.gasList,
                    min: entry.avgMin,
                    max: entry.avgMax
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
//                    Image("star")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
                }
                Spacer()
            }
            .padding()
            
//            VStack {
//                Spacer()
//                HStack {
//                    Text(entry.gasList.first?.SafeGasPrice ?? "00")
//                        .foregroundColor(Color("low"))
//                        .font(.system(size: 20, design: .rounded))
//                        .bold()
//                    Spacer()
//                    Text(entry.gasList.first?.FastGasPrice ?? "00")
//                        .foregroundColor(Color("high"))
//                        .font(.system(size: 20, design: .rounded))
//                        .bold()
//                }
//            }
//            .padding()
            
            VStack (alignment: .center) {
                Text(entry.gasList.first?.ProposeGasPrice ?? "00")
                    .font(.system(size: 90, design: .rounded)).bold()
                    .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                    .lineLimit(1)
                    .foregroundStyle(
                        Color("avg").gradient
                            .shadow(.inner(color: Color("avgLight").opacity(1), radius: 4, x: 0, y: 0))
                    )
                    .shadow(color: Color(.systemBackground), radius: 5)
            }
            .padding(.top)
        }
    }
}

struct EthGasWidget: Widget {
    let kind: String = "EthGasWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EthGasWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Large Average")
//        .description("A number for the average gas price.")
        .supportedFamilies([.systemSmall])
    }
}

struct EthGasWidget_Previews: PreviewProvider {
    static var previews: some View {
        EthGasWidgetEntryView(
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

extension Date {
    func relativeTime(in locale: Locale = .current) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
