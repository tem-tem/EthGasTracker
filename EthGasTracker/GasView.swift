//
//  GasView.swift
//  EthGasTracker
//
//  Created by Tem on 3/11/23.
//

import SwiftUI

struct GasView: View {
    @AppStorage("FastGasPrice") var high: String?
    @AppStorage("ProposeGasPrice") var avg: String?
    @AppStorage("SafeGasPrice") var low: String?
    @AppStorage("suggestBaseFee") var base: String = ""
    @AppStorage("gasUsedRatio") var usage: String?
    @AppStorage("LastBlock") var lastBlock: String?
    
    @AppStorage("timestamp") var timestamp: Int = 0
    
    @AppStorage("ethbtc") var ethbtc: String = ""
    @AppStorage("ethbtc_timestamp") var ethbtc_timestamp: String = ""
    @AppStorage("ethusd") var ethusd: String = ""
    @AppStorage("ethusd_timestamp") var ethusd_timestamp: String = ""
    
    @State private var highColor: Color = Color.red
    @State private var avgColor: Color = Color.blue
    @State private var lowColor: Color = Color.green
    @State private var baseColor: Color = Color.primary
    @State private var lastBlockColor: Color = Color.primary
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                CardView(
                    title: "ETH PRICE",
                    subtitle: "",
                    multiValue: ["$\(ethusd)", "BTC \(String(format: "%.5f", Float(ethbtc) ?? 0.0))"],
                    icon: "dollarsign.circle",
                    bgBase: Color(.systemBackground),
                    bgAccent: Color(.systemGray),
                    valueColor: $lastBlockColor,
                    secondary: true
                )
                
                CardView(
                    title: "HIGH",
                    subtitle: "",
                    value: shortenNumber(high ?? "0"),
                    icon: "arrow.up.right",
                    bgBase: Color.red,
                    bgAccent: Color.purple,
                    valueColor: $highColor,
                    emojii: "🚀"
                )
            }
            
            HStack(alignment: .top, spacing: 20) {
                CardView(
                    title: "BASE FEE",
                    subtitle: "",
                    value: String(format: "%.8f", Float(base) ?? 0.0),
                    icon: "light.max",
                    bgBase: Color(.systemBackground),
                    bgAccent: Color(.systemGray),
                    valueColor: $baseColor,
                    secondary: true
                )
                
                CardView(
                    title: "AVERAGE",
                    subtitle: "",
                    value: shortenNumber(avg ?? "0"),
                    icon: "circle.slash",
                    bgBase: Color.blue,
                    bgAccent: Color.purple,
                    valueColor: $avgColor,
                    emojii: "🌊"
                )
            }
            
            HStack(alignment: .top, spacing: 20) {
                CardView(
                    title: "GAS USAGE",
                    subtitle: "",
                    value:  "\(Int((Float(usage ?? "0") ?? 0) * 100))%",
                    icon: "chart.bar.fill",
                    bgBase: Color(.systemBackground),
                    bgAccent: Color(.systemGray),
                    valueColor: $lastBlockColor,
                    secondary: true
                )
                
                CardView(
                    title: "LOW",
                    subtitle: "",
                    value: shortenNumber(low ?? "0"),
                    icon: "arrow.down.forward",
                    bgBase: Color.green,
                    bgAccent: Color.blue,
                    valueColor: $lowColor,
                    emojii: "🐌"
                )
            }
        }
    }
    
    func getColor(prev: String?, curr: String?) -> Color {
        var status = Color.primary
        if (Double(prev ?? "0") ?? 0 > Double(curr ?? "0") ?? 0) {
            status = Color.green
        } else if (Double(prev ?? "0") ?? 0 < Double(curr ?? "0") ?? 0) {
            status = Color.red
        }
        return status
    }
    
    func shortenNumber(_ number: String) -> String {
        guard let value = Double(number) else {
            return "Invalid Input"
        }
        
        let thousand = 1000.0
        let million = 1000000.0
        
        if value < thousand {
            return String(format: "%.0f", value)
        } else if value < million {
            return String(format: "%.1fK", value / thousand)
        } else {
            return String(format: "%.1fM", value / million)
        }
    }

}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
