//
//  FetchView.swift
//  EthGasTracker
//
//  Created by Tem on 3/15/23.
//

import SwiftUI

struct FetchView: View {
    @Environment(\.scenePhase) var scene
    @ObservedObject var fetcherViewModel = FetcherViewModel()
    @AppStorage("timestamp") var timestamp: Int = 0
    
    @State private var animateLoadingBar = true
    @State private var fadeInFetching = false
    
    private let dotSize: CGFloat = 5
    
    var body: some View {
        VStack {
            switch fetcherViewModel.status {
            case .idle:
                TimerView()
            case .fetching:
                Text("Fetching")
                    .opacity(fadeInFetching ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3).delay(1), value: fadeInFetching)
                    .onAppear {
                        fadeInFetching = true
                    }
                    .onDisappear {
                        fadeInFetching = false
                    }
            case .failure(let error):
                Text("\(error.localizedDescription)")
            case .success:
                Text("OK")
            }
            
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: dotSize)
                    .fill(Color(.systemGray6))
                
                switch fetcherViewModel.status {
                case .idle:
                    RoundedRectangle(cornerRadius: dotSize)
                        .fill(.green)
                        .frame(width: animateLoadingBar ? 100 : dotSize, alignment: .center)
                        .animation(.easeInOut(duration: 10), value: animateLoadingBar)
                        .onAppear {
                            animateLoadingBar = false
                        }
                        .onDisappear {
                            animateLoadingBar = true
                        }
                case .fetching:
                    RoundedRectangle(cornerRadius: dotSize)
                        .fill(.yellow)
                        .frame(width: dotSize, alignment: .center)
                case .failure(_):
                    RoundedRectangle(cornerRadius: dotSize)
                        .fill(.red)
                        .frame(width: dotSize, alignment: .center)
                case .success:
                    RoundedRectangle(cornerRadius: dotSize)
                        .fill(.green)
                        .frame(width: dotSize, alignment: .center)
                }
            }
            .frame(width: 100, height: dotSize)
            
        }
        .onChange(of: scene) { newValue in
            switch newValue {
            case .active:
                fetcherViewModel.fetchData()
            default:
                break
            }
        }
    }
}
