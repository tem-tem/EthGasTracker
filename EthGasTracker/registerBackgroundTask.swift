//
//  registerBackgroundTask.swift
//  EthGasTracker
//
//  Created by Tem on 3/10/23.
//

import SwiftUI
import BackgroundTasks

func fetchData() {
    print("fetchData called")
    guard let url = URL(string: "http://65.109.175.89:8000/") else {
        return
    }

    let session = URLSession.shared
    let task = session.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        do {
            let dataResponse = try JSONDecoder().decode(GasData.self, from: data)
            UserDefaults.standard.set(dataResponse.FastGasPrice, forKey: "FastGasPrice")
            print("Fetched \(dataResponse)")
//            return dataResponse
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
        }
    }

    task.resume()
}
