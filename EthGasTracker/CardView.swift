//
//  CardView.swift
//  EthGasTracker
//
//  Created by Tem on 3/12/23.
//

import SwiftUI

struct CardView: View {
    var title: String
    var subtitle: String
    var value: String
    var icon: String
    var bgBase: Color
    var bgAccent: Color
    @Binding var valueColor: Color
    
    var body: some View {
        ZStack {
            Image(systemName: icon)
                .font(.system(size: 80, weight: .black))
                .foregroundColor(bgBase.opacity(0.2))
            HStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text(title)
                        Text(subtitle)
                    }.font(.caption)
                    Text(value)
                        .font(.system(size: value.count > 3 ? 24 : 60, weight: .medium))
                        .frame(height: 90, alignment: .bottom)
//                                .font(.largeTitle)
                        .foregroundColor(valueColor)
//                        .onChange(of: low, perform: {_ in
//                            lowColor = getColor(prev: prevLow, curr: low)
//
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                lowColor = Color.primary
//                            }
//                        })
                }
                
                Spacer()
                
            }
        }
        .padding(10)
        .shadow(color: .purple, radius: 50)
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(LinearGradient(gradient: Gradient(colors: [bgBase.opacity(0.3), bgAccent.opacity(0.1)]), startPoint: .bottomLeading, endPoint: .topTrailing))
        .cornerRadius(20)
    }
}

//struct CardView_Previews: PreviewProvider {
//    @State var color = Color.primary
//    
//    static var previews: some View {
//        CardView(title: "Test", subtitle: "sub", value: "234", icon: "arrow", bgBase: Color(.red), bgAccent: .blue, valueColor: $color)
//    }
//}
