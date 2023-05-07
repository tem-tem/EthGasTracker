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
    
    var body: some View {
        VStack (alignment: .center) {
            ZStack {
                AvgChart()
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
                            .padding(.leading, 10)
                        Text(avg)
                            .font(
                                .system(size: 80)
                                .bold()
                            )
                            .padding(.bottom, -10)
                            .padding(.top, -10)
                    }
                    .padding(.top, -1)
                    .padding(.bottom, 10)
                    
                    Spacer()
                }
            }
            
            HStack {
                ZStack {
                    LowChart()
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
                            Text(low).font(.system(size: 40))
                                .padding(.bottom, -10)
                        }
                        Spacer()
                    }
                }
                Spacer()
                ZStack {
                    HighChart()
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
                            Text(high).font(.system(size: 40))
                                .padding(.bottom, -10)
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
