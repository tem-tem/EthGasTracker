//
//  CardView.swift
//  EthGasTracker
//
//  Created by Tem on 3/12/23.
//

import SwiftUI

struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var title: String
    var subtitle: String
    var value: String?
    var multiValue: [String]?
    var icon: String
    var bgBase: Color
    var bgAccent: Color
    @Binding var valueColor: Color
    var secondary = false
    var emojii: String? = nil
    
    var body: some View {
        ZStack {
            Image(systemName: icon)
                .font(.system(size: 80, weight: .black))
                .foregroundColor((secondary ? bgBase : bgAccent).opacity(0.1))
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        if (emojii != nil) {
                            Text(emojii ?? "").font(.title)
                        }
                        VStack(alignment: .leading) {
                            Text(title)
                            Text(subtitle)
                        }.font(.caption)
                    }
                    Spacer()
                    HStack(alignment: .bottom) {
//                        Spacer()
                        if value != nil {
                            Text(value ?? "")
    //                            .frame(minHeight: 120, alignment: .bottom)
                                .font(.system(size: CGFloat(getFontSize(from: value ?? "0")), weight: .medium))
                                .padding(.bottom, secondary ? 10 : 0)
        //                                .font(.largeTitle)
                                .foregroundColor(valueColor)
                                .opacity(secondary ? 0.8 : 1)
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach((multiValue ?? [""]).indices, id: \.self) { index in
                                    let val = multiValue?[index] ?? ""
                                    Text(val)
                                        .font(.system(size: CGFloat(getFontSize(from: val)), weight: .medium))
                                        .foregroundColor(valueColor)
                                        .opacity(secondary ? 0.8 : 1)
                                        
                                    if index != (multiValue?.count ?? 1) - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 120)
                .opacity(secondary ? 0.8 : 1)
                
                Spacer()
                
            }
        }
        .padding(10)
        .shadow(color: bgBase, radius: colorScheme == .dark ? 10 : 0)
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(LinearGradient(gradient: Gradient(colors: [bgBase.opacity(colorScheme == .dark ? 0.2 : 0.1), bgAccent.opacity(0.25)]), startPoint: .bottomLeading, endPoint: .topTrailing))
        .cornerRadius(20)
    }
    
    func getFontSize(from value: String) -> Int {
        if (secondary) { return 24 }
            
        switch true {
        case value.count < 4:
            return 60
        case value.count < 5:
            return 50
        case value.count < 6:
            return 40
        default:
            return 24
        }
    }
}

//struct CardView_Previews: PreviewProvider {
//    @State var color = Color.primary
//    
//    static var previews: some View {
//        CardView(title: "Test", subtitle: "sub", value: "234", icon: "arrow", bgBase: Color(.red), bgAccent: .blue, valueColor: $color)
//    }
//}
