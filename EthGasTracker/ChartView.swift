//
//  ChartView.swift
//  EthGasTracker
//
//  Created by Tem on 3/12/23.
//
import SwiftUI
//import Charts

struct ChartView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text("test")
//                ForEach((1...10), id:\.self) {
////                    dataController.prices[$0].low
//                }
            }
        }
    }
}

//struct ChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartView()
//    }
//}
