////
////  GasLevelExplainerView.swift
////  EthGasTracker
////
////  Created by Tem on 11/10/23.
////
//
//import SwiftUI
//
//struct GasLevelExplainerView: View {
//    @EnvironmentObject var appDelegate: AppDelegate
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 0) {
//                Text("Gas Level Guide")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding(.vertical)
//
//                // Loop through all possible gas levels
//                ForEach((0...10).reversed(), id: \.self) { level in
//                    // skip level 4-7
//                    HStack {
////                        Rectangle()
////                            .fill(GasLevel.getColor(for: level))
////                            .frame(width: 20, height: 40)
//                        gasLevelRow(for: level)
////                        if (level < 4 || level > 8) {
////                            gasLevelRow(for: level)
////                        }
//                    }
//                }
//                Divider().padding(.vertical)
//                Text("Gas levels on the Ethereum network are not static throughout the day; they are dynamic and can shift significantly over short periods. For instance, a gas price of 19 gwei may be categorized as 'high' during a less busy time such as 10 am, but the very same price can be deemed 'normal' or even 'low' during peak transaction hours like 2 pm. It's important to understand that gas prices are relative and assessed within specific 10-minute intervals to provide a more accurate reflection of the network's current demand.")
//                    .padding(.vertical)
//            }
//            .padding()
//        }
//    }
//
//    // Function to create a row for each gas level
//    private func gasLevelRow(for level: Int) -> some View {
////        let gasLevel = GasLevel(currentStats: appDelegate.currentStats, currentGas:Double(level) * 10)
//        var label: String {
//            return GasLevel.getLabel(for: level)
//        }
//        var description: String {
//            return GasLevel.getDescription(for: level)
//        }
//        var color: Color {
//            return GasLevel.getColor(for: level)
//        }
//        var value:Double {
//            switch level {
//            case 10:
//                return appDelegate.currentStats.max
//            case 9:
//                return appDelegate.currentStats.p95
//            case 8:
//                return appDelegate.currentStats.p75
//            case 3:
//                return appDelegate.currentStats.p25
//            case 2:
//                return appDelegate.currentStats.p5
//            case 1:
//                return appDelegate.currentStats.min
//            default:
//                return 0
//            }
//        }
//
//        return HStack(alignment: .center) {
//            VStack(spacing: 0) {
//                if (level == 10) {
//                    Image(systemName: "arrow.up")
//                        .bold()
//                }
//                RoundedRectangle(cornerRadius: 2)
//                    .fill(color)
//                    .frame(width: 1, height: 40)
//                switch level {
//                case 10:
//                    Text("\(Int(appDelegate.currentStats.max))")
//                        .padding(.horizontal, 4)
//                        .border(color)
//                        .cornerRadius(2)
//                case 9:
//                    Text("\(Int(appDelegate.currentStats.p95))")
//                        .padding(.horizontal, 4)
//                        .border(color)
//                        .cornerRadius(2)
//                case 8:
//                    Text("\(Int(appDelegate.currentStats.p75))")
//                        .padding(.horizontal, 4)
//                        .border(color)
//                        .cornerRadius(2)
//                case 3:
//                    Text("\(Int(appDelegate.currentStats.p25))")
//                        .padding(.horizontal, 4)
//                        .border(color)
//                        .cornerRadius(2)
//                case 2:
//                    Text("\(Int(appDelegate.currentStats.p5))")
//                        .padding(.horizontal, 4)
//                        .border(color)
//                        .cornerRadius(2)
//                case 1:
//                    Text("\(Int(appDelegate.currentStats.min))")
//                        .padding(.horizontal, 4)
//                        .border(color)
//                        .cornerRadius(2)
//                case 0:
//                    Image(systemName: "arrow.down")
//                        .bold()
//                default:
//                    EmptyView()
//                }
//            }
//            .font(.caption)
//            .foregroundColor(color)
//            .frame(width: 40)
//            VStack(alignment: .leading) {
//                Text(label)
//                    .font(.caption)
//                    .bold()
//                    .foregroundColor(color)
//                Text(description)
//                    .font(.caption)
//            }
//            .opacity(.init(level < 3 || level > 7 || level == 5 ? 1 : 0))
////            .overlay(
////                Divider()
////                    .frame(width: 20)
////                    .background(color),
////                alignment: .leading
////            )
//        }
////        .padding(.vertical, 2)
//    }
//}
//
//struct GasLevelExplainerView_Previews: PreviewProvider {
//    static var previews: some View {
//        GasLevelExplainerView()
//    }
//}
