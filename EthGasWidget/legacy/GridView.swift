//
//  GridView.swift
//  EthGasWidgetExtension
//
//  Created by Tem on 6/20/23.
//

import SwiftUI

struct GridView: View {
    let rows: Int
    let columns: Int
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Drawing vertical lines
                ForEach(0..<columns + 1) { i in
                    Path { path in
                        let x = CGFloat(i) * geometry.size.width / CGFloat(columns)
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    .stroke(color, lineWidth: 1)
                }
                
                // Drawing horizontal lines
                ForEach(0..<rows + 1) { i in
                    Path { path in
                        let y = CGFloat(i) * geometry.size.height / CGFloat(rows)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(color, lineWidth: 1)
                }
            }
        }
    }
}

//struct ContentView: View {
//    var body: some View {
//        GridView(rows: 10, columns: 10)
//            .frame(width: 300, height: 300) // Specify the size of the parent view here
//            .border(Color.red) // Optional: Adding a border to clearly see the grid's bounds
//    }
//}
