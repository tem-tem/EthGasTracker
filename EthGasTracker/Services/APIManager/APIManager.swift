//
//  APIManager.swift
//  EthGasTracker
//
//  Created by Tem on 1/7/24.
//

import Foundation

class APIManager {
    let endpoints = Endpoints()
}

enum APIError: Error {
    case invalidURL
    case noData
}
