//
//  PlainGasView.swift
//  EthGasTracker
//
//  Created by Tem on 4/14/23.
//

import SwiftUI

struct PlainGasView: View {
    @AppStorage("FastGasPrice") var high = "00"
    @AppStorage("ProposeGasPrice") var avg = "00"
    @AppStorage("SafeGasPrice") var low = "00"
    @AppStorage("avgMin") var avgMin: Double = 0.0
    @AppStorage("avgMax") var avgMax: Double = 999.0
    @AppStorage("lowMin") var lowMin: Double = 0.0
    @AppStorage("lowMax") var lowMax: Double = 9999.0
    @AppStorage("highMin") var highMin: Double = 0.0
    @AppStorage("highMax") var highMax: Double = 9999.0
    
    private var gasListLoader = GasListLoader()
    private var gasList: [GasData]
    
    init() {
        gasList = gasListLoader.loadGasDataListFromUserDefaults()
    }
    
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            ZStack {
                AvgChart(gasList: gasList, min: avgMin, max: avgMax)
                    .frame(height: 120)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                
                Rectangle()
                  .fill(LinearGradient(
                    gradient: .init(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0), Color(.systemBackground).opacity(0)]),
                    startPoint: .leading,
                    endPoint: .trailing
                  ))
                  .frame(height: 140)
                
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("AVERAGE")
                            .foregroundColor(Color("avg"))
                            .font(.body.bold())
                            .padding(.leading, 2)
                        Text(avg)
                            .font(.system(size: 90, design: .rounded)).bold()
                            .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                            .lineLimit(1)
                            .foregroundStyle(
                                Color("avg").gradient
                                    .shadow(.inner(color: Color("avgLight").opacity(1), radius: 4, x: 0, y: 0))
                            )
                            .shadow(color: Color(.systemBackground), radius: 5)
                            .padding(.bottom, -10)
                            .padding(.top, -10)
                        Text("GWEI")
                            .font(.body.bold())
                            .padding(.leading, 10)
                    }
                    .padding(.top, -1)
                    .padding(.bottom, 10)
                    
                    Spacer()
                }
            }
            
            HStack {
                ZStack {
                    LowChart(
                        gasList: gasList, min: lowMin, max: lowMax
                    )
                        .frame(height: 50)
                        .padding(.leading, 20)
                        .padding(.trailing, 10)
                        .padding(.top, 20)
                    
                    Rectangle()
                      .fill(LinearGradient(
                        gradient: .init(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0)]),
                        startPoint: .leading,
                        endPoint: .trailing
                      ))
                      .frame(height: 140)
                    
                    HStack {
                        VStack (alignment: .leading) {
                            Text("LOW")
                                .foregroundColor(Color("low"))
                                .font(.caption.bold())
                                .padding(.leading, 4)
                            Text(low)
                                .font(.system(size: 40, design: .rounded)).bold()
                                .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                                .lineLimit(1)
                                .foregroundStyle(
                                    Color("low").gradient
                                        .shadow(.inner(color: Color("lowLight").opacity(1), radius: 2, x: 0, y: 0))
                                )
                                .shadow(color: Color(.systemBackground), radius: 5)
                                .padding(.bottom, -10)
                            Text("GWEI")
                                .font(.caption.bold())
                                .padding(.leading, 4)
                        }
                        Spacer()
                    }
                }
                Spacer()
                ZStack {
                    HighChart(
                        gasList: gasList, min: highMin, max: highMax
                    )
                        .frame(height: 50)
                        .padding(.leading, 20)
                        .padding(.trailing, 10)
                        .padding(.top, 20)
                    
                    Rectangle()
                      .fill(LinearGradient(
                        gradient: .init(colors: [Color(.systemBackground),  Color(.systemBackground).opacity(0)]),
                        startPoint: .leading,
                        endPoint: .trailing
                      ))
                      .frame(height: 140)
                    
                    HStack {
                        VStack (alignment: .leading) {
                            Text("HIGH")
                                .foregroundColor(Color("high"))
                                .font(.caption.bold())
                                .padding(.leading, 4)
                            Text(high)
                                .font(.system(size: 40, design: .rounded)).bold()
                                .minimumScaleFactor(0.1) // It will scale down to 10% of the original font size if needed
                                .lineLimit(1)
                                .foregroundStyle(
                                    Color("high").gradient
                                        .shadow(.inner(color: Color("highLight").opacity(1), radius: 3, x: 0, y: 0))
                                )
                                .padding(.bottom, -10)
                            Text("GWEI")
                                .font(.caption.bold())
                                .padding(.leading, 4)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct PlainGasView_Previews: PreviewProvider {
    static var previews: some View {
        PlainGasView()
    }
}
