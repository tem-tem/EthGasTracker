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
        VStack(alignment: .trailing, spacing: 10) {
            HStack(alignment: .top) {
                HStack(alignment: .top) {
                    Image(systemName: "cube").frame(width: 10).font(.system(size: 18, weight: .light))
                    Text("LAST BLOCK")
                        .font(.system(size: 20, weight: .light))
                }
                Spacer()
                Text(lastBlock ?? "0")
                    .font(.system(size: 20, weight: .light))
//                    .padding(.vertical, -30)
//                    .padding(.bottom, 10)
            }
            .padding(10)
            .padding(.bottom, 10)
//            Divider()
            HStack(alignment: .top) {
                HStack(alignment: .top) {
                    Image(systemName: "arrow.down.forward").padding(.top, 0).frame(width: 10).font(.system(size: 20, weight: .light))
                    VStack(alignment: .leading) {
                        Text("LOW").font(.system(size: 20, weight: .light))
                        Text("LAST: ").font(.caption) +
                        Text(prevLow ?? "0").font(.caption)
                    }
                }
                Spacer()
                Text(low ?? "0")
                    .font(.system(size: 80, weight: .light))
                    .padding(.vertical, -15)
                    .padding(.bottom, 50)
                    .foregroundColor(lowColor)
                    .onChange(of: low, perform: {_ in
                        lowColor = getColor(prev: prevLow, curr: low)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            lowColor = Color.primary
                        }
                    })
            }
            .padding(10)
            .background(Color.green.opacity(0.25))
            .cornerRadius(10)
            .shadow(radius: 4)
//            Divider()
            HStack(alignment: .top) {
                HStack(alignment: .top) {
                    Image(systemName: "circle.slash").frame(width: 10).font(.system(size: 16, weight: .light))
                    VStack(alignment: .leading) {
                        Text("AVERAGE").font(.system(size: 20, weight: .light)).padding(.leading, -3)
                        Text("LAST: ").font(.caption) +
                        Text(prevAvg ?? "0").font(.caption)
                    }
                }
                Spacer()
                Text(avg ?? "0")
                    .font(.system(size: 80, weight: .light))
                    .padding(.vertical, -15)
                    .padding(.bottom, 50)
                    .foregroundColor(avgColor)
                    .onChange(of: avg, perform: {_ in
                        avgColor = getColor(prev: prevAvg, curr: avg)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            avgColor = Color.primary
                        }
                    })
            }
            .padding(10)
            .background(Color.blue.opacity(0.25))
            .cornerRadius(10)
            .shadow(radius: 4)
//            Divider()
            HStack(alignment: .top) {
                HStack(alignment: .top) {
                    Image(systemName: "arrow.up.right").padding(.top, 3).frame(width: 10).font(.system(size: 20, weight: .light))
                    VStack(alignment: .leading) {
                        Text("HIGH").font(.system(size: 20, weight: .light))
                        Text("LAST: ").font(.caption) +
                        Text(prevHigh ?? "0").font(.caption)
                    }
                }
                Spacer()
                Text(high ?? "0")
                    .font(.system(size: 80, weight: .light))
                    .padding(.vertical, -15)
                    .padding(.bottom, 50)
                    .foregroundColor(highColor)
                    .onChange(of: high, perform: {_ in
                        highColor = getColor(prev: prevHigh, curr: high)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            highColor = Color.primary
                        }
                    })
            }
            .padding(10)
            .background(Color.red.opacity(0.25))
            .cornerRadius(10)
            .shadow(radius: 4)
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

struct GasView_Previews: PreviewProvider {
    static var previews: some View {
        GasView()
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
