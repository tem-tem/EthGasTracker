//
//  GasFetcher.swift
//  EthGasTracker
//
//  Created by Tem on 3/15/23.
//

import Foundation
import Starscream

class GasFetcher: ObservableObject {
    @Published var gasResponse: GasResponse = GasResponse()
    
    private var socket: WebSocket!
    
    func connect() {
        let request = URLRequest(url: URL(string: "wss://your-websocket-url")!)
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
}

extension GasFetcher: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            print("Connected to WebSocket, headers: \(headers)")
        case .disconnected(let reason, let code):
            print("Disconnected from WebSocket, reason: \(reason), code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            if let data = string.data(using: .utf8),
               let decodedResponse = try? JSONDecoder().decode(GasResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.gasResponse = decodedResponse
                }
            } else {
                print("Error decoding the response")
            }
        case .binary(let data):
            print("Received binary data: \(data)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("WebSocket cancelled")
        case .error(let error):
            print("WebSocket error: \(String(describing: error))")
        }
    }
}
