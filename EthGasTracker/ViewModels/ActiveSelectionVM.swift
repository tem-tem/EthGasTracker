//
//  ActiveSelectionViewModel.swift
//  EthGasTracker
//
//  Created by Tem on 1/8/24.
//

import Foundation

class ActiveSelectionViewModel: ObservableObject {
    @Published var date: Date? = nil
    @Published var price: Float? = nil
    @Published var key: String? = nil
    @Published var index: Int? = nil
}
