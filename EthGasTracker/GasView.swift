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
    @AppStorage("lastBlock") var lastBlock: String?
    
    @AppStorage("prevHigh") var prevHigh: String?
    @AppStorage("prevAvg") var prevAvg: String?
    @AppStorage("prevLow") var prevLow: String?
    
    @State private var highColor: Color = Color.primary
    @State private var avgColor: Color = Color.primary
    @State private var lowColor: Color = Color.primary
    @State private var lastBlockColor: Color = Color.primary
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                
                CardView(
                    title: "HIGH",
                    subtitle: "LAST: \(prevHigh ?? "0")",
                    value: high ?? "0",
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
                    value: avg ?? "0",
                    icon: "circle.slash",
                    bgBase: Color.green,
                    bgAccent: Color.blue,
                    valueColor: $avgColor
                ).onChange(of: low, perform: {_ in
                    lowColor = getColor(prev: prevLow, curr: low)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        lowColor = Color.primary
                    }
                })
            }
            HStack(alignment: .top, spacing: 20) {
                CardView(
                    title: "LOW",
                    subtitle: "LAST: \(prevLow ?? "0")",
                    value: low ?? "0",
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
                    title: "LAST BLOCK",
                    subtitle: "",
                    value: lastBlock ?? "0",
                    icon: "cube",
                    bgBase: Color.gray,
                    bgAccent: Color(.systemGray4),
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
        if (Int(prev ?? "0") ?? 0 > Int(curr ?? "0") ?? 0) {
            status = Color.green
        } else if (Int(prev ?? "0") ?? 0 < Int(curr ?? "0") ?? 0) {
            status = Color.red
        }
        return status
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
