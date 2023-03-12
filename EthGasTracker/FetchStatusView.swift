//
//  FetchStatusView.swift
//  EthGasTracker
//
//  Created by Tem on 3/11/23.
//

import SwiftUI

struct FetchStatusView: View {
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @AppStorage("high") var high: String?
    @AppStorage("avg") var avg: String?
    @AppStorage("low") var low: String?
    @AppStorage("base") var base: String?
    @AppStorage("lastBlock") var lastBlock: String?
    
    @AppStorage("prevHigh") var prevHigh: String?
    @AppStorage("prevAvg") var prevAvg: String?
    @AppStorage("prevLow") var prevLow: String?
    @AppStorage("prevBase") var prevBase: String?
    
    @AppStorage("timestamp") var timestamp: String?
    @State private var secondsLeft = 10
    
    @State private var pending = false
    @State private var fetchError = false
    
    let formatter = DateFormatter()
    
    var body: some View {
        VStack() {
            HStack {
                if (fetchError) {
                    Text("Something is wrong 🤷‍♂️")
                } else {
                    Text("LAST UPDATE")
                }
                Spacer()
                VStack {
                    if (pending) {
                        ProgressView()
                    } else {
                        if networkMonitor.isConnected {
                            if (fetchError) {
                                Image(systemName: "exclamationmark.triangle").foregroundColor(.orange).onTapGesture {
                                    pending = true
                                    fetchError = false
                                    fetchGas(completion: handleResponse)
                                }
                            } else {
                                Text(formatter.string(from: Date(timeIntervalSince1970: Double(timestamp ?? "0.0")!)))
                            }
                        } else {
                            Image(systemName: "xmark.icloud").foregroundColor(.red)
                        }
                    }
                }
            }.font(.system(size: 20, weight: .light))

            GeometryReader { metrics in
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 5)
//                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .red]), startPoint: .leading, endPoint: .trailing))
                        .fill(Color(.systemGray6))
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(.systemBackground))
                        .frame(width: (metrics.size.width * CGFloat(secondsLeft == 0 ? 10 : secondsLeft ) / 10), alignment: .trailing)
                        .animation(.easeInOut(duration: secondsLeft == 10 ? 0.2 : 1))
                }
                .frame(height: 5)
                .opacity(fetchError ? 0 : 1)

            }
        }
        .frame(height: 30)
        .onAppear() {
            formatter.dateFormat = "HH:mm:ss"
            
            secondsLeft = getTimeTillNextCall()
            countdown()
        }
        .onChange(of: high, perform: { _ in
            dataController.addGasPrice(low: low ?? "0", avg: avg ?? "0", high: high ?? "0")
        })
    }
    
    func countdown() {
        secondsLeft -= 1
        if secondsLeft < 1 {
            secondsLeft = 10
            pending = true
            fetchGas(completion: handleResponse)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                countdown()
            }
        }
    }
    
    func handleResponse(response: GasResponse?, error: Error?) {
        guard error == nil else {
            print("Error fetching gas price: \(String(describing: error))")
            fetchError = true
            pending = false
            return
        }
        guard response?.message == "OK" else {
            print("Bad response: \(String(describing: response?.message))")
            fetchError = true
            pending = false
            return
        }
        
        if (response?.result?.SafeGasPrice != nil) {
            prevHigh = high
            prevAvg = avg
            prevLow = low
            prevBase = base
            
            high = response?.result?.FastGasPrice
            avg = response?.result?.ProposeGasPrice
            low = response?.result?.SafeGasPrice
            base = response?.result?.suggestBaseFee
            lastBlock = response?.result?.LastBlock
            timestamp = String(Date().timeIntervalSince1970)
        }
        pending = false
        countdown()
        
    }
    
    func getTimeTillNextCall() -> Int {
        var timeTillNextCall = 10
        if (timestamp != nil) {
            let timestampAsDate = Date(timeIntervalSince1970: Double(timestamp ?? "0.0")!)
            let elapsed = Date().timeIntervalSince(timestampAsDate)
            if (elapsed < 10) {
                timeTillNextCall = Int(elapsed)
            } else {
                timeTillNextCall = 0
            }
        }
        return timeTillNextCall
    }
}
