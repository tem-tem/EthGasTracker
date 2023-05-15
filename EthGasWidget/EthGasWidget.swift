//
//  EthGasWidget.swift
//  EthGasWidget
//
//  Created by Tem on 5/15/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    // when there's no data
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    // show actual data (e.g. picking a widget to put on)
//    recommended to not do network calls lol
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

//    timeline is array of entries
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// a data that i populate the widget with
struct SimpleEntry: TimelineEntry {
    let date: Date
}

// view
struct EthGasWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
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
        EthGasWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
