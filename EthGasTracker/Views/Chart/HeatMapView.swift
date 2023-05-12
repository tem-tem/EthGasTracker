//
//  HeatMapView.swift
//  EthGasTracker
//
//  Created by Tem on 5/12/23.
//

import SwiftUI

struct HeatMapView: View {
    private var statsLoader = StatsLoader()
    private var stats: [Stat]
    
    init() {
        stats = statsLoader.loadStatsFromUserDefaults()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Last \(stats.count / 24) days").font(.title2).bold()
            Divider()
            HStack (alignment: .top) {
                VStack {
                    ForEach(0..<24) { hour in
                        Text(String(format: "%02d:00", hour))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(height: 12.24)
                            .padding(.bottom, 2)
                            .padding(.top, 2)
                    }
                }.padding(.top, 5)
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal) {
                        HeatMap()
                            .frame(height: 600)
                            .padding(.bottom, 20)
                            .id("HeatmapChart")
                    }
                    .onAppear {
                        scrollToTheEnd(using: scrollProxy, id: "HeatmapChart")
                    }
                }
                
            }
        }
    }
    
    private func scrollToTheEnd(using scrollProxy: ScrollViewProxy, id: String) {
        withAnimation {
            scrollProxy.scrollTo(id, anchor: .trailing)
        }
    }
}

struct HeatMapView_Previews: PreviewProvider {
    static var previews: some View {
        HeatMapView()
    }
}
