//
//  BtcMempool.swift
//  EthGasTracker
//
//  Created by Tem on 2/20/24.
//

import SwiftUI

struct BtcMempool: View {
    @EnvironmentObject var liveDataVM: LiveDataVM
    
    var histogram: [Int: [Int]] {
        liveDataVM.btcDataEntity.histogram
    }
    
    var cols: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 2), count: 4)
    }
    
    var body: some View {
//        HStack {
//            Text("Mempool")
//                .font(.caption)
//                .foregroundStyle(.secondary)
//            Spacer()
//        }
//        .padding(.horizontal)
//        .padding(.top, 5)
        
        LazyVGrid(columns: cols, spacing: 15) {
            ForEach(histogram.keys.sorted().prefix(12), id: \.self) { time in
                if let fees = histogram[time],
                   let lRange = fees.first,
                   let rRange = fees.last {
                    
                    VStack(alignment: .leading) {
                        Text("~\(time) min")
                            .font(.caption)
//                            .opacity(0.5)
                        HStack {
                            if lRange == rRange {
                                Text("\(lRange)")
                            } else {
                                Text("\(lRange) - \(rRange)")
                            }
                        }
                        .font(.system(.caption, design: .monospaced, weight: .bold))
                        Text("sat/vB")
                            .font(.caption)
                            .opacity(0.5)
                        if (time < 90) {
                            Divider()
                                .overlay(.primary)
                                .opacity(0.2)
                        } else {
                            HStack {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .id(time)
                }
            }
        }
//        ScrollView(.horizontal) {
//            ScrollViewReader { value in
//                HStack {
//                    ForEach(histogram.keys.sorted().reversed(), id: \.self) { time in
//                        if let fees = histogram[time],
//                           let lRange = fees.first,
//                           let rRange = fees.last {
//                            
//                            VStack(alignment: .leading) {
//                                HStack {
//                                    if lRange == rRange {
//                                        Text("\(lRange)")
//                                    } else {
//                                        Text("\(lRange) - \(rRange)")
//                                    }
//                                }
//                                .font(.system(.caption, design: .monospaced, weight: .bold))
//                                Text("sat/vB")
//                                    .font(.caption)
//                                    .foregroundStyle(.secondary)
//                                Divider()
//                                Text("~\(time) min")
//                                    .font(.caption)
//                            }
//                            .padding(.horizontal, 10)
//                            .id(time)
//                        }
//                    }
//                }
//                .onAppear {
//                    // Scroll to the last element (which is the first due to the reversed order)
//                    if let lastTime = histogram.keys.sorted().first {
//                        print("Last time: \(lastTime)")
//                        value.scrollTo(lastTime, anchor: .trailing)
//                    }
//                }
//            }
//        }
    }
}

#Preview {
    PreviewWrapper {
        BtcMempool()
            .background(Color(.systemOrange))
    }
}
