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
    
    private let dotSize: CGFloat = 3
    
    var body: some View {
        VStack(alignment: .trailing) {
            switch fetcherViewModel.status {
            case .idle:
                TimerView().font(.caption)
//                Text("")
            case .fetching:
                Text("Fetching")
                    .opacity(fadeInFetching ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3).delay(1), value: fadeInFetching)
                    .onAppear {
                        fadeInFetching = true
                    }
                    .onDisappear {
                        fadeInFetching = false
                    }.font(.caption)
            case .failure(let error):
                Text("\(error.localizedDescription)").multilineTextAlignment(.center).font(.subheadline)
            case .success:
                Text("OK").font(.caption)
            }
            
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: dotSize)
                    .fill(Color(.systemGray6))
                
                switch fetcherViewModel.status {
                case .idle:
                    RoundedRectangle(cornerRadius: dotSize)
                        .fill(.gray)
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
                fetcherViewModel.fetchStatsOnAppear()
            default:
                break
            }
        }
    }
}
