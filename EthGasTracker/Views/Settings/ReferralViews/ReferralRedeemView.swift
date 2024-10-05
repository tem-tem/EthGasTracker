//
//  ReferralRedeemView.swift
//  EthGasTracker
//
//  Created by Tem on 10/3/24.
//

import SwiftUI
import AlertToast

struct ReferralRedeemView: View {
    @EnvironmentObject var alertToastManager: AlertToastManager
    var onSuccess: (() -> Void)?
    @State private var showReferralSheet = false
    @State private var userReferralCode = ReferralCodeManager.shared.getReferralCode()
    @AppStorage("points") var points = 0
    @AppStorage("subbed", store: UserDefaults(suiteName: "group.TA.EthGas")) var subbed: Bool = PlusFeatureManager.shared.hasPremiumAccess()
    
    @State private var pending = false
    
    @State private var months = 1.0
    
    var cost: Double {
        months * 4
    }
    
    let primary = Color.primary
    
    let apiManager = APIManager()
    
    var body: some View {
        VStack {
            Text("Redeem \(cost, specifier: "%.f") points")
                .font(.title)
                .padding()
            VStack {
                Text("\(months, specifier: "%.f")")
                    .lineLimit(1)
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                Text("Month\(months > 1 ? "s" : "") of Gas Plus features")
                    .padding(.bottom)
                Slider(
                    value: $months,
                    in: 1...12,
                    step: 1,
                    onEditingChanged: { _ in
                        //                    isEditing = editing
                    }
                )
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray3), lineWidth: 1)
            )
            .padding()
            
        
            Button {
                if Int(cost) > points {
                    alertToastManager.showError("Not enough points", displayMode: .hud)
                    return
                } else {
                    guard let referralCode = ReferralCodeManager.shared.getReferralCode() else { return }
                    let secret = ReferralCodeManager.shared.getSecretCode()
                    
                    apiManager.redeemReferralPoints(requestBody: RedeemPointsRequest(
                        referralCode: referralCode,
                        secret: secret,
                        points: Int(cost)
                    )) {
                        switch $0 {
                        case .success:
                            points -= Int(cost)
                            UserDefaults.standard.set(points, forKey: "points")
                            let endOfAccess = PlusFeatureManager.shared.getPremiumExpirationDate() ?? Date()
                            let calendar = Calendar.current
                            let expirationDate = calendar.date(byAdding: .month, value: Int(months), to: endOfAccess)!
                            PlusFeatureManager.shared.setPremiumExpirationDate(expirationDate)
                            subbed = PlusFeatureManager.shared.hasPremiumAccess()
                            onSuccess?()
                        case .failure(let error):
                            alertToastManager.showError(error.localizedDescription, displayMode: .hud)
                        }
                    }
                }
            } label: {
                HStack {
                    Text("Continue")
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                .foregroundColor(.white)
            }
            .buttonStyle(.borderless)
            .padding(.top)
            
            Text("Available points: \(points)")
                .padding()
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    PreviewWrapper {
        ReferralRedeemView()
    }
}
