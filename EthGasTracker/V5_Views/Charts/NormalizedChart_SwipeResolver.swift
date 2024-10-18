import SwiftUI
import Charts

struct NormalizedChart_SwipeResolver: View {
    var proxy: ChartProxy
    var chartType: ChartTypes
    @EnvironmentObject var activeSelectionVM: ActiveSelectionVM
    @EnvironmentObject var liveDataVM: LiveDataVM
    @EnvironmentObject var historicalDataVM: HistoricalDataVM

    var body: some View {
        GeometryReader { geometry in
            Rectangle().fill(Color.clear).contentShape(Rectangle())
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { value in
                            let origin = geometry[proxy.plotAreaFrame].origin
                            let location = CGPoint(
                                x: value.location.x - origin.x,
                                y: value.location.y - origin.y
                            )

                            // Handle data selection based on chart type
                            handleDataSelection(location: location, proxy: proxy)
                        }
                        .onEnded { _ in
                            activeSelectionVM.drop() // Clear selection on gesture end
                        }
                )
        }
    }

    // Handle data selection for both live and historical data
    private func handleDataSelection(location: CGPoint, proxy: ChartProxy) {
        if chartType == .live {
            updateLiveDataSelection(location: location, proxy: proxy)
        } else {
            updateHistoricalDataSelection(location: location, proxy: proxy)
        }
    }

    // Update active selection for live data
    private func updateLiveDataSelection(location: CGPoint, proxy: ChartProxy) {
        guard let index = proxy.value(atX: location.x, as: Int.self) else { return }
        let clampedIndex = min(max(0, index), liveDataVM.gasDataEntity.entries.count - 1)
        let entry = liveDataVM.gasDataEntity.entries[clampedIndex]

        updateActiveSelection(index: clampedIndex, gas: entry.normal, date: entry.date, key: entry.key, chartType: .live, historicalData: nil)
    }

    // Update active selection for historical data
    private func updateHistoricalDataSelection(location: CGPoint, proxy: ChartProxy) {
        guard let index = proxy.value(atX: location.x, as: Int.self) else { return }
        let entries = getHistoricalDataEntries(for: chartType)
        let clampedIndex = min(max(0, index), entries.count - 1)
        let entry = entries[clampedIndex]

        updateActiveSelection(index: clampedIndex, gas: entry.avg, date: entry.date, key: nil, chartType: chartType, historicalData: entry)
    }

    // Unified method to update the active selection
    private func updateActiveSelection(index: Int, gas: Double?, date: Date, key: String?, chartType: ChartTypes, historicalData: HistoricalData?) {
        activeSelectionVM.index = index
        activeSelectionVM.gas = gas
        activeSelectionVM.date = date
        activeSelectionVM.key = key
        activeSelectionVM.chartType = chartType
        activeSelectionVM.historicalData = historicalData
    }

    // Get historical data entries based on chart type
    private func getHistoricalDataEntries(for type: ChartTypes) -> [HistoricalData] {
        switch type {
        case .hour:
            return historicalDataVM.hour.gasListNormal
        case .day:
            return historicalDataVM.day.gasListNormal
        case .week:
            return historicalDataVM.week.gasListNormal
        case .month:
            return historicalDataVM.month.gasListNormal
        default:
            return []
        }
    }
}
