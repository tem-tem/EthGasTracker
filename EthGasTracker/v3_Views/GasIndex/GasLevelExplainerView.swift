//
//  GasLevelExplainerView.swift
//  EthGasTracker
//
//  Created by Tem on 11/10/23.
//

import SwiftUI

struct GasLevelExplainerView: View {
    @EnvironmentObject var appDelegate: AppDelegate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Gas Level Guide")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical)

                // Loop through all possible gas levels
                ForEach((0...10).reversed(), id: \.self) { level in
                    // skip level 4-7
                    HStack {
//                        Rectangle()
//                            .fill(GasLevel.getColor(for: level))
//                            .frame(width: 20, height: 40)
                        gasLevelRow(for: level)
//                        if (level < 4 || level > 8) {
//                            gasLevelRow(for: level)
//                        }
                    }
                }
                Divider().padding(.vertical)
                Text("Our gas price level statistics are tailored to reflect the current market conditions. They are calculated by aggregating gas data from the past 7 days, updated every 10 minutes to align with the latest 10-minute timeframe. This approach ensures that the level indicated is always relative to the typical values for the current time, providing a real-time assessment of whether the gas prices are high or low at any given moment.")
                    .padding(.vertical)
            }
            .padding()
        }
    }

    // Function to create a row for each gas level
    private func gasLevelRow(for level: Int) -> some View {
//        let gasLevel = GasLevel(currentStats: appDelegate.currentStats, currentGas: Float(level) * 10)
        var label: String {
            return GasLevel.getLabel(for: level)
        }
        var description: String {
            return GasLevel.getDescription(for: level)
        }
        var color: Color {
            return GasLevel.getColor(for: level)
        }

        return HStack(alignment: .center) {
            VStack(spacing: 0) {
                if (level == 10) {
                    Image(systemName: "arrow.up")
                        .bold()
                }
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 1, height: 40)
                switch level {
                case 10:
                    Text("MAX")
                case 9:
                    Text("95th")
                case 8:
                    Text("75th")
                case 3:
                    Text("25th")
                case 2:
                    Text("5th")
                case 1:
                    Text("MIN")
                case 0:
                    Image(systemName: "arrow.down")
                        .bold()
                default:
                    EmptyView()
                }
            }
            .font(.caption)
            .foregroundColor(color)
            .frame(width: 40)
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .bold()
                    .foregroundColor(color)
                Text(description)
                    .font(.caption)
            }
            .opacity(.init(level < 3 || level > 7 || level == 5 ? 1 : 0))
//            .overlay(
//                Divider()
//                    .frame(width: 20)
//                    .background(color),
//                alignment: .leading
//            )
        }
//        .padding(.vertical, 2)
    }
}

struct GasLevelExplainerView_Previews: PreviewProvider {
    static var previews: some View {
        GasLevelExplainerView()
    }
}
