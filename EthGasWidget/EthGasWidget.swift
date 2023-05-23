//
//  EthGasWidget.swift
//  EthGasWidget
//
//  Created by Tem on 5/15/23.
//

import WidgetKit
import SwiftUI

// a data that i populate the widget with
struct GasListEntry: TimelineEntry {
    let date: Date
    let gasList: [GasData]
}

struct Provider: TimelineProvider {
    private let api = MyAPI()
    
    typealias Entry = GasListEntry
    // when there's no data
    func placeholder(in context: Context) -> GasListEntry {
        GasListEntry(date: Date(), gasList: [])
    }

    // show actual data (e.g. picking a widget to put on)
    func getSnapshot(in context: Context, completion: @escaping (GasListEntry) -> Void) {
        let entry = GasListEntry(date: Date(), gasList: [])
            completion(entry)
        }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        
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
            let entry = GasListEntry(date: date, gasList: gasListData)
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
        VStack(alignment: .leading) {
            Text("AVERAGE").font(.caption)
            Text(entry.gasList.first?.ProposeGasPrice ?? "00")
                .font(.largeTitle).bold()
                .padding(.leading, -2)
            Text("GWEI")
            Spacer()
            Text(Date(timeIntervalSince1970: TimeInterval(entry.gasList.first?.timestamp ?? 0)), style: .relative)
                .font(.caption2)
                .foregroundColor(.gray)
            + Text(" ago")
                .font(.caption2)
                .foregroundColor(.gray)
        }.padding()
    }
}

struct EthGasWidget: Widget {
    let kind: String = "EthGasWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EthGasWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct EthGasWidget_Previews: PreviewProvider {
    static var previews: some View {
        EthGasWidgetEntryView(entry: GasListEntry(date: Date(), gasList: []))
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
