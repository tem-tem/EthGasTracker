//
//  GasTrends.swift
//  EthGasTracker
//
//  Created by Tem on 8/12/23.
//

import SwiftUI

struct GasTrendsView: View {
    @AppStorage("gas.timeframe") var timeframe = TimeFrame.live
    @EnvironmentObject var appDelegate: AppDelegate
    @AppStorage(SettingsKeys().isFastMain) private var isFastMain = false
    private var entries: [GasIndexEntity.ListEntry] {
        appDelegate.gasIndexEntries
    }
    private var avg: Float {
        guard entries.count > 0 else {
            return 0.0
        }
        return entries.map { $0.normal }.reduce(0, +) / Float(entries.count)
    }
    
    private var medianNormal: Float {
        guard entries.count > 0 else {
            return 0.0
        }
        let sortedNormals = entries.map { $0.normal }.sorted()
        return sortedNormals.count % 2 == 0 ?
            (sortedNormals[sortedNormals.count/2 - 1] + sortedNormals[sortedNormals.count/2]) / 2 :
            sortedNormals[sortedNormals.count/2]
    }
    
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Past \(timeframe.fullLengthName)").bold()
//                Spacer()
                if let first = isFastMain ? entries.first?.fast : entries.first?.normal,
                   let last = isFastMain ? entries.last?.fast : entries.last?.normal,
                   let diff = abs(last - first)
                {
                    HStack {
                        Image(systemName: last > first ? "arrow.up.right" : "arrow.down.right")
                        Text(String(format: "%.2f", diff)).bold()
                    }
                    .foregroundStyle(last > first ? Color(.systemRed) : Color.accentColor)
                }
            }
            .font(.title)
            .padding(.vertical)
            LazyVGrid(columns: columns) {
                ValueCard(value: appDelegate.gasIndexEntriesMinMax.max, label: "Maximum", systemName: "arrow.up")
                ValueCard(value: avg, label: "Average", systemName: "circle.slash")
                ValueCard(value: appDelegate.gasIndexEntriesMinMax.min, label: "Minimum", systemName: "arrow.down")
    //            ValueCard(value: medianNormal, systemName: "median")
                
            }
        }
    }
}

struct ValueCard: View {
    var value: Float?
    var label: String
    var systemName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: systemName)
                Text(label)
            }.font(.caption)
            Divider()
            Text(String(format: "%.2f", value ?? 0.0))
//                .font(.title)
                .bold()
//                .padding()
//            Divider()
//            Text(label)
//                .padding(.bottom)
//                .padding(.leading)
        }
//        .background(.ultraThinMaterial)
//        .cornerRadius(20)
    }
}

struct GasTrends_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            GasTrendsView()
        }
    }
}
