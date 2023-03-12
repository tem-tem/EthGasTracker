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
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                ZStack {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(Color.red.opacity(0.2))
                    HStack {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("HIGH")
                                Text("LAST: ") +
                                Text(prevHigh ?? "0")
                            }.font(.caption)
                            
                            Text(high ?? "0")
                                .font(.system(size: 80, weight: .light))
    //                            .font(.largeTitle)
                                .foregroundColor(highColor)
                                .onChange(of: high, perform: {_ in
                                    highColor = getColor(prev: prevHigh, curr: high)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        highColor = Color.primary
                                    }
                                })
                        }
                        Spacer()
                    }
                    
                }
                .padding(10)
                .frame(maxWidth: .infinity, minHeight: 150)
                .background(Color.red.opacity(0.25))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.red, lineWidth: 1)
                )
                
                ZStack {
                    Image(systemName: "circle.slash")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(Color.green.opacity(0.2))
                    HStack {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("AVERAGE")
                                Text("LAST: ") +
                                Text(prevAvg ?? "0")
                            }.font(.caption)
                            
                            Text(avg ?? "0")
                                .font(.system(size: 80, weight: .light))
                                .foregroundColor(avgColor)
                                .onChange(of: avg, perform: {_ in
                                    avgColor = getColor(prev: prevAvg, curr: avg)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        avgColor = Color.primary
                                    }
                                })
                        }
                        
                        Spacer()
                        
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, minHeight: 150)
                .background(Color.green.opacity(0.25))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green, lineWidth: 1)
                )
            }
            HStack(alignment: .top, spacing: 20) {
                ZStack {
                    Image(systemName: "arrow.down.forward")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(Color.blue.opacity(0.2))
                    HStack {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("LOW")
                                Text("LAST: ") +
                                Text(prevLow ?? "0")
                            }.font(.caption)
                            Text(low ?? "0")
                                .font(.system(size: 80, weight: .light))
                                .foregroundColor(lowColor)
                                .onChange(of: low, perform: {_ in
                                    lowColor = getColor(prev: prevLow, curr: low)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        lowColor = Color.primary
                                    }
                                })
                        }
                        
                        Spacer()
                        
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, minHeight: 150)
                .background(Color.blue.opacity(0.25))
                .cornerRadius(20)
    //            .shadow(radius: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue, lineWidth: 1)
                )
    //            Divider()
                
                ZStack {
                    Image(systemName: "cube")
                        .font(.system(size: 80, weight: .black))
                        .foregroundColor(Color(.systemGray5))
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
    //                        Image(systemName: "cube")
                            Text("LAST BLOCK").font(.caption)
                            Spacer()
                        }
    //                    Spacer()
                        Text(lastBlock ?? "0")
                            .font(.system(size: 20, weight: .light))
        //                    .padding(.vertical, -30)
                            .padding(.top, 60)
                        
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150)
                .background(Color(.systemGray6))
                .cornerRadius(20)
    //            .shadow(radius: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.systemGray), lineWidth: 1)
                )
                
            }
            
//            .shadow(radius: 4)
//            Divider()
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
