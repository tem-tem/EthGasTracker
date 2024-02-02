//
//  LimitView.swift
//  EthGasTracker
//
//  Created by Tem on 5/24/23.
//

import SwiftUI

enum AlertLimit: Int, CaseIterable, Identifiable {
//    case noLimit = 10
//    case one = 60
    case five = 300
    case ten = 600
    case fifteen = 900
    case twenty = 1200
    case thirty = 1800
    case fortyFive = 2700
    case oneHour = 3600
    case twoHours = 7200

    var id: Int { self.rawValue }

    var description: String {
        switch self {
//            case .noLimit:
//                return "No Limit"
//            case .one:
//                return "1 minute"
            case .five:
                return "5 Minutes"
            case .ten:
                return "10 Minutes"
            case .fifteen:
                return "15 Minutes"
            case .twenty:
                return "20 Minutes"
            case .thirty:
                return "30 Minutes"
            case .fortyFive:
                return "45 Minutes"
            case .oneHour:
                return "1 Hour"
            case .twoHours:
                return "2 Hours"
        }
    }
}

enum AlertConfirmation: Int, CaseIterable, Identifiable {
//    case noLimit = 10
//    case one = 60
    case one = 5
    case two = 10
    case three = 15
    case four = 20
    case five = 25

    var id: Int { self.rawValue }

    var description: String {
        switch self {
//            case .noLimit:
//                return "No Limit"
//            case .one:
//                return "1 minute"
            case .one:
                return "1 Minute"
            case .two:
                return "2 Minutes"
            case .three:
                return "3 Minutes"
            case .four:
                return "4 Mintues"
            case .five:
                return "5 Minutes"
        }
    }
}

enum AlertLifespan: Int, CaseIterable, Identifiable {
//    case noLimit = 10
//    case one = 60
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case ten = 10

    var id: Int { self.rawValue }

    var description: String {
        switch self {
//            case .noLimit:
//                return "No Limit"
//            case .one:
//                return "1 minute"
        case .one:
            return "1"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .ten:
            return "10"
        }
    }
}

struct AlertLimitPicker: View {
    @Binding var selectedLimit: AlertLimit

    var body: some View {
        VStack(alignment: .center) {
//            if (selectedLimit.rawValue < 300) {
//                Text("Warning: ").foregroundColor(.orange) +
//                Text("may lead to frequent notifications.")
//            } else {
//                Text("Limit to one per \(selectedLimit.description)")
//            }
            Picker("Limit", selection: $selectedLimit) {
                ForEach(AlertLimit.allCases) { limit in
                    Text(limit.description).tag(limit)
                }
            }.pickerStyle(.navigationLink)
//            if (selectedLimit.rawValue == 10) {
//                Text("Not recommended: You will get notified every time gas hits your target, which might get frustrating (especially overnight).")
//            }
        }
    }
}


struct LimitView_Previews: PreviewProvider {
//    @State private var selectedLimit =
    static var previews: some View {
        AlertLimitPicker(selectedLimit: .constant(AlertLimit.oneHour))
    }
}
