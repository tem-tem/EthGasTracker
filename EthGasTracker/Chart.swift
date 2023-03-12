//
//  Chart.swift
//  EthGasTracker
//
//  Created by Tem on 3/12/23.
//

import SwiftUI
import Charts

struct Chart: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        GroupBox ( "Line Chart - Step Count") {
//            Chart {
//                ForEach(dataController.prices) {
//                    LineMark(
//                        x: .value("day", $0.lastUpdate ?? Date(), unit: .day),
//                        y: .value("high", Int($0.high ?? 0))
//                    )
//                }
//            }
        }
    }
}
