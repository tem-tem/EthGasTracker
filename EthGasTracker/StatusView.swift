//
//  StatusView.swift
//  EthGasTracker
//
//  Created by Tem on 3/15/23.
//

import SwiftUI

struct StatusView: View {
    @ObservedObject var gasFetcher: GasFetcher
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var pending = false
    @State private var fetchError = false
    @State private var drawingWidth = false
    
    @State private var timerString = "00:00"
    
    let formatter = DateFormatter()
    
    var body: some View {
        HStack {
            Text("Updated ") +
            Text(timerString)
                .font(.caption.bold()) +
            Text(" ago")
            
            Spacer()
            
            if (pending) {
                ProgressView()
            } else {
                if networkMonitor.isConnected {
                    if (fetchError) {
                        Text("Something is wrong 🤷‍♂️")
                        Image(systemName: "exclamationmark.triangle").foregroundColor(.orange).onTapGesture {
                            pending = true
                            fetchError = false
                            gasFetcher.connect()
                        }
                    } else {
                        ZStack(alignment: .trailing) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(.systemGray6))
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.green)
                                .frame(width: drawingWidth ? 100 : 0, alignment: .trailing)
                                .animation(.easeOut(duration: 10), value: drawingWidth)
                        }
                        .frame(width: 100, height: 5)
                        .onAppear {
                            drawingWidth = false
                        }
                        .onDisappear {
                            drawingWidth = true
                        }
                    }
                } else {
                    Text("No internet")
                    Image(systemName: "xmark.icloud").foregroundColor(.red)
                }
            }
        }.font(.caption).frame(height: 20)
        .onReceive(gasFetcher.$gasResponse.publisher, perform: { gasResponse in
            timerString = gasResponse.timestamp.passedTime(from: Date(timeIntervalSince1970: gasResponse.timestamp))
        })
    }
}

