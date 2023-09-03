//
//  EthPriceChart.swift
//  EthGasTracker
//
//  Created by Tem on 8/9/23.
//

import SwiftUI
import Charts

struct EthPriceChart: View {
    let priceEntity: PriceDataEntity
    private var minMax: (min: Float, max: Float)? {
        priceEntity.minMaxEntries()
    }
    private let gradient = LinearGradient(
        gradient: Gradient (
            colors: [
                .secondary.opacity(0.5),
                .secondary.opacity(0.0),
            ]
        ),
        startPoint: .top,
        endPoint: .bottom
    )
    private let color = Color.secondary
    private let lineGradient = Gradient(colors: [Color.secondary, Color.primary])
    
    var body: some View {
        Chart(priceEntity.getEntriesDict(), id: \.self.key) {
            LineMark(
                x: .value("Time", Date(timeIntervalSince1970: TimeInterval($0.key)!)),
                y: .value("Price", $0.value.price)
            )
            .lineStyle(StrokeStyle(lineWidth: 1))
            .foregroundStyle(lineGradient)
            
            AreaMark(
                x: .value("Time", Date(timeIntervalSince1970: TimeInterval($0.key)!)),
                yStart: .value("Price Start", $0.value.price),
                yEnd: .value("Price End", minMax?.min ?? 0)
            )
            .foregroundStyle(gradient)
        }
        .chartYScale(domain: (minMax?.min ?? 0)...(minMax?.max ?? 10))
        .chartLegend(.hidden)
        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
    }
}
