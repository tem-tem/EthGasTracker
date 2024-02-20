//
//  CustomNumberPadView.swift
//  EthGasTracker
//
//  Created by Tem on 2/2/24.
//
import SwiftUI

struct CustomNumberPadView: View {
    @Binding var value: String
    var canCreate: Bool = false
    var onCommit: () -> Void
    var accentColor: Color = Color(.systemGreen)
    
    private var commitUnlocked: Bool {
        return !value.isEmpty && canCreate
    }

    let gridItems = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let color = Color.secondary
    let height = 40.0

    var body: some View {
        VStack {
//            Text("Value: \(value)")
//                .padding()
//                .font(.largeTitle)

            LazyVGrid(columns: gridItems, spacing: 10) {
                ForEach(1...9, id: \.self) { num in
                    Button(action: {
                        appendNumber(num)
                    }) {
                        Text("\(num)")
                            .bold()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: height)
                            .foregroundStyle(color)
                            .cornerRadius(10)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .circular)
                                    .strokeBorder(color, lineWidth: 1)
                                    .opacity(0.5)
                            }
                                
                    }
                }
                
                Button(action: {
                    if commitUnlocked {
                        onCommit()
                    }
                }) {
                    Image(systemName: "checkmark")
                        .font(.headline)
                        .bold(commitUnlocked)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: height)
                        .foregroundStyle(commitUnlocked ? Color(.systemBackground) : color)
                        .background(commitUnlocked ? accentColor : Color.clear)
                        .cornerRadius(10)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 10, style: .circular)
//                                .strokeBorder(value.isEmpty ? color : Color.clear, lineWidth: 1)
//                                .opacity(0.5)
//                        }
                }.disabled(value.isEmpty)
                
                Button(action: {
                    appendNumber(0)
                }) {
                    Text("0")
                        .font(.headline)
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: height)
                        .foregroundStyle(color)
                        .cornerRadius(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .circular)
                                .strokeBorder(color, lineWidth: 1)
                                .opacity(0.5)
                        }
                }
                
                Button(action: {
                    if !value.isEmpty {
                        value = String(value.dropLast())
                    }
                }) {
                    Image(systemName: "delete.left")
                        .font(.headline)
//                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: height)
                        .foregroundStyle(color)
                        .cornerRadius(20)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 10, style: .circular)
//                                .strokeBorder(color, lineWidth: 1)
//                        }
                }
            }
        }
        .padding()
    }

    private func appendNumber(_ number: Int) {
        if value.isEmpty && number == 0 {
            // Prevent adding a leading zero
            return
        }
        
        let newValue = "\(value)\(number)"
        if let intValue = Int(newValue), intValue <= 9999 {
            value = newValue
        }
    }
}

struct CustomNumberPadView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNumberPadView(value: .constant(""), onCommit: {})
    }
}
