//
//  GasView.swift
//  EthGasTracker
//
//  Created by Tem on 3/11/23.
//

import SwiftUI

struct GasView: View {
    @AppStorage("high") var high: String?
    @AppStorage("avg") var avg: String?
    @AppStorage("low") var low: String?
    @AppStorage("base") var base: String?
    @AppStorage("usage") var usage: String?
    
    @AppStorage("prevHigh") var prevHigh: String?
    @AppStorage("prevAvg") var prevAvg: String?
    @AppStorage("prevLow") var prevLow: String?
    @AppStorage("prevBase") var prevBase: String?
    @AppStorage("prevUsage") var prevUsage: String?
    
    @AppStorage("lastBlock") var lastBlock: String?
    
    @State private var highColor: Color = Color.primary
    @State private var avgColor: Color = Color.primary
    @State private var lowColor: Color = Color.primary
    @State private var baseColor: Color = Color.primary
    @State private var lastBlockColor: Color = Color.primary
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                CardView(
                    title: "HIGH",
                    subtitle: "LAST: \(prevHigh ?? "0")",
                    value: shortenNumber(high ?? "0"),
                    icon: "arrow.up.right",
                    bgBase: Color.red,
                    bgAccent: Color.purple,
                    valueColor: $highColor
                ).onChange(of: high, perform: {_ in
                    highColor = getColor(prev: prevHigh, curr: high)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        highColor = Color.primary
                    }
                })
                
                CardView(
                    title: "AVERAGE",
                    subtitle: "LAST: \(prevAvg ?? "0")",
                    value: shortenNumber(avg ?? "0"),
                    icon: "circle.slash",
                    bgBase: Color.green,
                    bgAccent: Color.blue,
                    valueColor: $avgColor
                ).onChange(of: avg, perform: {_ in
                    avgColor = getColor(prev: prevAvg, curr: avg)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        avgColor = Color.primary
                    }
                })
            }
            
            HStack(alignment: .top, spacing: 20) {
                CardView(
                    title: "LOW",
                    subtitle: "LAST: \(prevLow ?? "0")",
                    value: shortenNumber(low ?? "0"),
                    icon: "arrow.down.forward",
                    bgBase: Color.purple,
                    bgAccent: Color.blue,
                    valueColor: $lowColor
                ).onChange(of: low, perform: {_ in
                    lowColor = getColor(prev: prevLow, curr: low)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        lowColor = Color.primary
                    }
                })
                
                
                CardView(
                    title: "BASE FEE",
                    subtitle: "LAST: \(prevBase ?? "0")",
                    value: shortenNumber(base ?? "0"),
                    icon: "light.max",
                    bgBase: Color.yellow,
                    bgAccent: Color.green,
                    valueColor: $baseColor
                ).onChange(of: base, perform: {_ in
                    baseColor = getColor(prev: prevBase, curr: base)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        baseColor = Color.primary
                    }
                })
            }
            
            HStack(alignment: .top, spacing: 20) {
                
                CardView(
                    title: "GAS USAGE",
                    subtitle: "",
                    value:  "\(Int((Float(usage ?? "0") ?? 0) * 100))%",
                    icon: "chart.bar.fill",
                    bgBase: Color.orange,
                    bgAccent: Color.pink,
                    valueColor: $lastBlockColor
                ).onChange(of: lastBlock, perform: {_ in
                    lastBlockColor = Color.green
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        lastBlockColor = Color.primary
                    }
                })
                
                CardView(
                    title: "LAST BLOCK",
                    subtitle: "",
                    value: lastBlock ?? "0",
                    icon: "cube",
                    bgBase: Color(.systemBackground),
                    bgAccent: Color(.systemGray),
                    valueColor: $lastBlockColor
                ).onChange(of: lastBlock, perform: {_ in
                    lastBlockColor = Color.green
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        lastBlockColor = Color.primary
                    }
                })
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
