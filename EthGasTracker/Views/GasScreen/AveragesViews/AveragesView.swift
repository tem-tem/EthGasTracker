//
//  AveragesView.swift
//  EthGasTracker
//
//  Created by Tem on 10/21/24.
//

import SwiftUI
import Charts

struct AveragesChartViewController: View {
    @EnvironmentObject var viewModel: AveragesViewModel
    
    @AppStorage("subbed", store: UserDefaults(suiteName: "group.TA.EthGas")) var subbed: Bool = false
    
    @State var range: AveragesRange = .week
    @State var weekday: AveragesWeekday?
    @State private var averagesEntries: [AverageEntry] = []
    @State private var activeEntry: AverageEntry?
    
    @State private var pending: Bool = false
    
    var paywall: Bool {
        return !subbed && (range != .week || weekday != nil)
    }
    
    var body: some View {
        VStack {
            if pending {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                if averagesEntries.isEmpty {
                    VStack {
                        Spacer()
                        Text("No data available.")
                        Spacer()
                    }
                } else {
                    if paywall {
                        VStack {
                            Spacer()
                            Text("Unlock full access to gas fee averages and more! The free version shows data for the last 7 days only.")
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                            SubscriptionView(source: "eth_historical_charts")
                                .padding(.bottom)
                        }
                    } else {
                        VStack {
                            AveragesEntryPercentilesView(entry: $activeEntry)
                            Divider()
                                .padding(.vertical, 10)
                            AveragesEntryMinMaxView(entry: $activeEntry)
                        }
                        .padding(10)
                        .background(Color("BG.L1"))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                        
                        AveragesEntryAvgTimeView(entry: $activeEntry)
                            .background(Color("BG.L1"))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding(.horizontal, 10)
                        
                        AveragesChartView(
                            averagesEntries: $averagesEntries,
                            activeEntry: $activeEntry
                        )
                        .background(Color("BG.L1"))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal, 10)
                    }
                }
            }
            AveragesChartMenuView(range: $range, weekday: $weekday)
        }
        .onAppear {
            getAverageEntries()
        }
        .onChange(of: range) { _ in
            getAverageEntries()
            updateActiveEntry()
        }
        .onChange(of: weekday) { _ in
            getAverageEntries()
            updateActiveEntry()
        }
    }
    
    func updateActiveEntry() {
        if let entry = activeEntry {
            activeEntry = averagesEntries.first { $0.minuteOfDay == entry.minuteOfDay }
        }
    }
    
    func getAverageEntries() {
        guard paywall == false else { return }
        
        pending = true
        viewModel.fetchAverages(for: range, weekday: weekday) { result in
            switch result {
            case .success(let entries):
                if subbed {
                    averagesEntries = entries
                } else {
                    averagesEntries = filterHourValues(from: entries)
                }
            case .failure(let error):
                print(error)
            }
            pending = false
        }
    }
    
    func filterHourValues(from entries: [AverageEntry]) -> [AverageEntry] {
        return entries.filter { $0.minuteOfDay % 60 == 0 }
    }

}

struct AveragesEntryTimeView: View {
    @Binding var entry: AverageEntry?
    
    var body: some View {
        if let entry = entry {
            let hour = entry.minuteOfDay / 60
            let minute = entry.minuteOfDay % 60
            Text("\(String(format: "%02d:%02d", hour, minute))")
                .font(.system(.body, design: .monospaced))
        } else {
            Text("No entry selected.")
        }
    }
}

struct AveragesEntryMinMaxView: View {
    @Binding var entry: AverageEntry?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Min")
                    .font(.caption)
                Text("\(String(format: "%.1f", entry?.min ?? 0))")
                    .font(.system(.body, design: .monospaced, weight: .bold))
                HStack { Spacer() }
            }
            Spacer()
            VStack(alignment: .center) {
                Text("Fluctuation")
                    .font(.caption)
                Text("\(String(format: "%.1f", entry?.deviation ?? 0))")
                    .font(.system(.body, design: .monospaced, weight: .bold))
                HStack { Spacer() }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Max")
                    .font(.caption)
                Text("\(String(format: "%.1f", entry?.max ?? 0))")
                    .font(.system(.body, design: .monospaced, weight: .bold))
                HStack { Spacer() }
            }
        }
    }
}

struct AveragesEntryAvgTimeView: View {
    @Binding var entry: AverageEntry?
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            HStack { Spacer() }
            Text("Average")
                .font(.caption)
            Text("\(String(format: "%.1f", entry?.avg ?? 0))")
                .font(.system(size: 120, weight: .black, design: .monospaced))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Spacer()
            AveragesEntryTimeView(entry: $entry)
                .padding(.bottom)
        }
    }
}

struct AveragesEntryPercentilesView: View {
    @Binding var entry: AverageEntry?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("p5")
                    .font(.system(.caption, design: .monospaced, weight: .light))
                Text(String(format: "%.1f", entry?.p5 ?? 0))
                HStack { Spacer() }
            }

            Spacer()

            VStack(alignment: .leading) {
                Text("p25")
                    .font(.system(.caption, design: .monospaced, weight: .light))
                Text(String(format: "%.1f", entry?.p25 ?? 0))
                HStack { Spacer() }
            }

            Spacer()

            VStack(alignment: .center) {
                Text("p50")
                    .font(.system(.caption, design: .monospaced, weight: .light))
                Text(String(format: "%.1f", entry?.p50 ?? 0))
                HStack { Spacer() }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("p75")
                    .font(.system(.caption, design: .monospaced, weight: .light))
                Text(String(format: "%.1f", entry?.p75 ?? 0))
                HStack { Spacer() }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("p95")
                    .font(.system(.caption, design: .monospaced, weight: .light))
                Text(String(format: "%.1f", entry?.p95 ?? 0))
                HStack { Spacer() }
            }
        }
        .font(.system(.caption, design: .monospaced, weight: .bold))

    }
}

struct AveragesChartMenuView: View {
    @Binding var range: AveragesRange
    @Binding var weekday: AveragesWeekday?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Range")
                    .font(.caption)
                Picker("Range", selection: $range) {
                    ForEach(AveragesRange.allCases, id: \.self) { range in
                        Text(range.displayName).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color("BG.L1"))
            }
            
            VStack(alignment: .trailing) {
                Text("Weekday")
                    .font(.caption)
                Picker("Weekday", selection: $weekday) {
                    // Add an option for "None" to handle the case when no weekday is selected
                    Text("All").tag(AveragesWeekday?.none)
                    
                    ForEach(AveragesWeekday.allCases, id: \.self) { weekday in
                        Text(weekday.displayName).tag(weekday as AveragesWeekday?)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding()
    }
}

struct AveragesChartView: View {
    @Binding var averagesEntries: [AverageEntry]
    @Binding var activeEntry: AverageEntry?
    
    @AppStorage("subbed", store: UserDefaults(suiteName: "group.TA.EthGas")) var subbed: Bool = false
    
    @State private var minuteOfDay = 0
    @AppStorage(SettingsKeys().hapticFeedbackEnabled) private var haptic = true
    let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    // Dictionary for efficient lookup
    @State private var minuteToEntryMap: [Int: AverageEntry] = [:]

    var body: some View {
        AveragesChartRendererView(
            averagesEntries: $averagesEntries,
            activeMinuteOfDay: $minuteOfDay
        )
            .chartOverlay { proxy in
                AveragesSwipeResolver(
                    proxy: proxy,
                    minuteOfDay: $minuteOfDay
                )
            }
            .onAppear {
                // Set current minute of the day when view appears
                let currentHour = Calendar.current.component(.hour, from: Date())
                let currentMinute = Calendar.current.component(.minute, from: Date())
                
                // Calculate total minutes since the start of the day
                let totalMinutes = currentHour * 60 + currentMinute
                
                // Clamp and round to the nearest 10-minute increment
                minuteOfDay = min(max((totalMinutes / 10) * 10, 0), 1430)
            }
            .onAppear {
                minuteOfDay = getCurrentMinuteOfDay()
                // Create a hashmap of minuteOfDay -> AverageEntry for faster lookups
                minuteToEntryMap = Dictionary(uniqueKeysWithValues: averagesEntries
                    .filter { $0.measureName == "normal" }
                    .map { ($0.minuteOfDay, $0) })
                
                // Set the initial active entry based on the current minute
                activeEntry = minuteToEntryMap[minuteOfDay]
            }
            .onChange(of: minuteOfDay) { newMinuteOfDay in
                if haptic {
                    hapticFeedbackGenerator.impactOccurred()
                }

                // Use the hashmap to find the active entry in constant time
                activeEntry = minuteToEntryMap[newMinuteOfDay]
            }
    }
    
    func getCurrentMinuteOfDay() -> Int {
        if subbed {
            // Set current minute of the day when view appears
            let currentHour = Calendar.current.component(.hour, from: Date())
            let currentMinute = Calendar.current.component(.minute, from: Date())
            
            // Calculate total minutes since the start of the day
            let totalMinutes = currentHour * 60 + currentMinute
            
            // Clamp and round to the nearest 10-minute increment
            return min(max((totalMinutes / 10) * 10, 0), 1430)
        } else {
            // Get current hour in minutes of the day
            let currentHour = Calendar.current.component(.hour, from: Date())
            return currentHour * 60
        }
    }
}

struct AveragesSwipeResolver: View {
    var proxy: ChartProxy
    @Binding var minuteOfDay: Int
    
    @AppStorage("subbed", store: UserDefaults(suiteName: "group.TA.EthGas")) var subbed: Bool = false
    
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle().fill(.clear).contentShape(Rectangle())
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { value in
                            // Get the origin of the plot area inside the geometry
                            let origin = geometry[proxy.plotAreaFrame].origin
                            let location = CGPoint(
                                x: value.location.x - origin.x,
                                y: value.location.y - origin.y
                            )

                            // Get the index (in minutes) from the X location, convert it to Int
                            guard let index = proxy.value(atX: location.x, as: Int.self) else {
                                return
                            }
                            
                            // Clamp the index between 0 and 1430 (as we have 1440 minutes in a day)
                            let clampedIndex = min(max(0, index), 1430)
                            
                            // Apply logic based on subscription
                            if subbed {
                                // Snap to nearest 10-minute increment
                                minuteOfDay = (clampedIndex / 10) * 10
                            } else {
                                // Snap to the nearest hour (in minutes)
                                minuteOfDay = (clampedIndex / 60) * 60
                            }
                        }
                        .onEnded { _ in
                            // When the drag ends, set minuteOfDay to the current time
                            let currentMinute = Calendar.current.component(.hour, from: Date()) * 60 +
                                                Calendar.current.component(.minute, from: Date())
                            if subbed {
                                // Snap to the nearest 10-minute increment
                                minuteOfDay = (currentMinute / 10) * 10
                            } else {
                                // Snap to the nearest hour
                                minuteOfDay = (currentMinute / 60) * 60
                            }
                        }
                )
        }
    }
}


struct AveragesChartRendererView: View {
    @Binding var averagesEntries: [AverageEntry]
    @Binding var activeMinuteOfDay: Int
    
    var avgMax: Double {
        averagesEntries
            .filter { $0.measureName == "normal" }
            .max { $0.avg < $1.avg }?.avg ?? 0
    }
    
    var avgMin: Double {
        averagesEntries
            .filter { $0.measureName == "normal" }
            .min { $0.avg < $1.avg }?.avg ?? 0
    }
    
    let primaryColor: Color = .primary

    var body: some View {
        Chart {
            ForEach(averagesEntries, id: \.minuteOfDay) { entry in
                if entry.measureName == "normal" {
                    AreaMark(
                        x: .value("Minute of Day", entry.minuteOfDay),
                        y: .value("Average", entry.avg)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [Color(.systemGreen).opacity(0), Color(.systemBlue).opacity(0.3), Color(.systemYellow).opacity(0.6), Color(.systemRed)],
                            startPoint: .bottom, endPoint: .top
                        ).opacity(0.5)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round))
                    .alignsMarkStylesWithPlotArea()
                    
                    if #available(iOS 16.4, *) {
                        LineMark(
                            x: .value("Minute of Day", entry.minuteOfDay),
                            y: .value("Average", entry.avg)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color(.systemGreen), Color(.systemBlue), Color(.systemYellow), Color(.systemRed)],
                                startPoint: .bottom, endPoint: .top
                            )
                        )
                        .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round))
                        .alignsMarkStylesWithPlotArea()
                        .shadow(color: Color(.systemBlue).opacity(0.5), radius: 5, x: 0, y: 0)
                    } else {
                        LineMark(
                            x: .value("Minute of Day", entry.minuteOfDay),
                            y: .value("Average", entry.avg)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color(.systemGreen), Color(.systemBlue), Color(.systemYellow), Color(.systemRed)],
                                startPoint: .bottom, endPoint: .top
                            )
                        )
                        .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round))
                        .alignsMarkStylesWithPlotArea()
                    }
                    
                    if entry.minuteOfDay == activeMinuteOfDay {
                        
                        RuleMark(
                            x: .value("Minute of Day", activeMinuteOfDay)
                        )
                            .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round, dash: [5]))
                            .foregroundStyle(.linearGradient(colors: [primaryColor, .clear], startPoint: .top, endPoint: .bottom))
                        
                        RuleMark(
                            x: .value("Minute of Day", activeMinuteOfDay),
                            yStart: .value("Average", avgMin),
                            yEnd: .value("Average", entry.avg)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                        .foregroundStyle(.linearGradient(colors: [primaryColor, .clear], startPoint: .top, endPoint: .bottom))
                        
                        PointMark(
                            x: .value("Minute of Day", entry.minuteOfDay),
                            y: .value("Average", entry.avg)
                        )
                        .foregroundStyle(primaryColor)
                        .symbol(Circle())
                        .symbolSize(100)
                    }
                    
                    if entry.avg == avgMax || entry.avg == avgMin {
                        if #available(iOS 16.4, *) {
                            PointMark(
                                x: .value("Minute of Day", entry.minuteOfDay),
                                y: .value("Average", entry.avg)
                            )
                            .foregroundStyle(entry.avg == avgMax ? .red : .green)
                            .shadow(color: entry.avg == avgMax ? .red : .green, radius: 5, x: 0, y: 0)
                            .annotation(position: entry.avg == avgMax ? .bottom : .top) {
                                Text(String(format: "%.1f", entry.avg))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(5)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                        } else {
                            
                            PointMark(
                                x: .value("Minute of Day", entry.minuteOfDay),
                                y: .value("Average", entry.avg)
                            )
                            .foregroundStyle(entry.avg == avgMax ? .red : .green)
                            .annotation(position: entry.avg == avgMax ? .bottom : .top) {
                                Text(String(format: "%.1f", entry.avg))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(5)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
        .chartYScale(domain: avgMin...(avgMax * 1.1))
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: Array(stride(from: 0, to: 1440, by: 180))) { value in
                AxisTick()
                if let minuteOfDay = value.as(Int.self) {
                    AxisGridLine()
                    AxisValueLabel(centered: false, collisionResolution: .disabled, offsetsMarks: true) {
                        let hour = minuteOfDay / 60
                        Text(String(format: "%02d:00", hour))
                    }
                }
            }
        }
    }
}


#Preview {
    PreviewWrapper {
        AveragesChartViewController()
    }
}
