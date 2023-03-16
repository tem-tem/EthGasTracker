////
////  FetchStatusView.swift
////  EthGasTracker
////
////  Created by Tem on 3/11/23.
////
//
//import SwiftUI
//
//struct FetchStatusView: View {
//    @EnvironmentObject var dataController: DataController
//    @EnvironmentObject var networkMonitor: NetworkMonitor
//    @AppStorage("high") var high: String?
//    @AppStorage("avg") var avg: String?
//    @AppStorage("low") var low: String?
//    @AppStorage("base") var base: String?
//    @AppStorage("usage") var usage: String?
//    @AppStorage("lastBlock") var lastBlock: String?
//
//    @AppStorage("prevHigh") var prevHigh: String?
//    @AppStorage("prevAvg") var prevAvg: String?
//    @AppStorage("prevLow") var prevLow: String?
//    @AppStorage("prevBase") var prevBase: String?
//    @AppStorage("prevUsage") var prevUsage: String?
//
//    @AppStorage("timestamp") var timestamp: String?
//    @State private var secondsLeft = 1
//
//    @State private var pending = false
//    @State private var fetchError = false
//
//    @State private var drawingWidth = false
//
//    @State private var timerString = "00:00"
////    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//
//    let formatter = DateFormatter()
//
//    var body: some View {
//        VStack() {
//            HStack {
//                Text("Updated ") +
////                Text(formatter.string(from: Date(timeIntervalSince1970: Double(timestamp ?? "0.0")!)))
//                Text(timerString)
//                    .font(.caption.bold()) +
//                Text(" ago")
//
//                Spacer()
//
//                if (pending) {
//                    ProgressView()
//                } else {
//                    if networkMonitor.isConnected {
//                        if (fetchError) {
//                            Text("Something is wrong 🤷‍♂️")
//                            Image(systemName: "exclamationmark.triangle").foregroundColor(.orange).onTapGesture {
//                                pending = true
//                                fetchError = false
////                                fetchGas(completion: handleResponse)
//                            }
//                        } else {
//                            ZStack(alignment: .trailing) {
//                                RoundedRectangle(cornerRadius: 5)
//                                    .fill(Color(.systemGray6))
//                                RoundedRectangle(cornerRadius: 5)
//                                    .fill(.green)
//                                    .frame(width: drawingWidth ? 100 : 0, alignment: .trailing)
//                                    .animation(.easeOut(duration: 10), value: drawingWidth)
//                            }
//                            .frame(width: 100, height: 5)
//                            .onAppear {
//                                drawingWidth = false
//                            }
//                            .onDisappear {
//                                drawingWidth = true
//                            }
//                        }
//                    } else {
//                        Text("No internet")
//                        Image(systemName: "xmark.icloud").foregroundColor(.red)
//                    }
//                }
//            }.font(.caption).frame(height: 20)
//
//
//        }
//        .frame(height: 30)
//        .onAppear() {
//            formatter.dateFormat = "HH:mm:ss"
//
//            secondsLeft = getTimeTillNextCall()
//            countdown()
//            drawingWidth = true
//            timer()
//
//        }
//        .onChange(of: high, perform: { _ in
//            dataController.addGasPrice(low: low ?? "0", avg: avg ?? "0", high: high ?? "0")
//        })
//    }
//
//    func timer() {
//        timerString = Date().passedTime(from: Date(timeIntervalSince1970: Double(timestamp ?? "0.0")!))
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            timer()
//        }
//    }
//
//    func countdown() {
//        secondsLeft -= 1
//        if secondsLeft < 1 {
//            secondsLeft = 10
//            pending = true
//            fetchGas(completion: handleResponse)
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                countdown()
//            }
//        }
//    }
//
//    func handleResponse(response: GasResponse?, error: Error?) {
//        guard error == nil else {
//            print("Error fetching gas price: \(String(describing: error))")
//            fetchError = true
//            pending = false
//            return
//        }
//        guard response?.message == "OK" else {
//            print("Bad response: \(String(describing: response?.message))")
//            fetchError = true
//            pending = false
//            return
//        }
//
//        if (response?.result?.SafeGasPrice != nil) {
//            prevHigh = high
//            prevAvg = avg
//            prevLow = low
//            prevBase = base
//            prevUsage = usage
//
//            high = response?.result?.FastGasPrice
//            avg = response?.result?.ProposeGasPrice
//            low = response?.result?.SafeGasPrice
//            base = response?.result?.suggestBaseFee
//            usage = calculateAverage(numbersString: response?.result?.gasUsedRatio ?? "0")
//
//            lastBlock = response?.result?.LastBlock
//            timestamp = String(Date().timeIntervalSince1970)
//        }
//        pending = false
//        countdown()
//    }
//
//    func getTimeTillNextCall() -> Int {
//        var timeTillNextCall = 0
//        if (timestamp != nil) {
//            let timestampAsDate = Date(timeIntervalSince1970: Double(timestamp ?? "0.0")!)
//            let elapsed = Date().timeIntervalSince(timestampAsDate)
//            if (elapsed < 10) {
//                timeTillNextCall = Int(elapsed)
//            }
//        }
//        return timeTillNextCall
//    }
//
//    func calculateAverage(numbersString: String) -> String? {
//        let numbers = numbersString.split(separator: ",")
//                                   .compactMap { Float($0) }
//        guard !numbers.isEmpty else { return nil }
//        let average = numbers.reduce(0, +) / Float(numbers.count)
//        return String(format: "%.2f", average)
//    }
//
//}
//
//extension Date {
//    func passedTime(from date: Date) -> String {
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.hour, .minute, .second], from: date, to: self)
//
//        guard let hours = components.hour,
//              let minutes = components.minute,
//              let seconds = components.second
//        else {
//            return ""
//        }
//
//        let timeString: String
//
//        if hours > 0 {
//            timeString = String(format: "%d:%d:%d", hours, minutes, seconds)
//        } else if minutes > 0 {
//            timeString = String(format: "%d:%d", minutes, seconds)
//        } else {
//            timeString = String(format: "%ds", seconds)
//        }
//
//        return timeString
//    }
//}
