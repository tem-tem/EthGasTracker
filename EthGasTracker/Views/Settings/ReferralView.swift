//
//  ReferralView.swift
//  EthGasTracker
//
//  Created by Tem on 9/29/24.
//

import SwiftUI

struct ReferralView: View {
    @State private var pending: Bool = false
    @State private var referralCode: String = ""
    @State private var availablePoints: Int = 0
    
    var body: some View {
        VStack {
            if referralCode.isEmpty {
                ReferralCreatorView(code: $referralCode, points: $availablePoints)
            } else {
                ShareReferralView(userReferralCode: referralCode)
            }
        }
        .onAppear {
            if let code = ReferralCodeManager.shared.getReferralCode() {
                referralCode = code
            }
        }
    }
}

struct ReferralCreatorView: View {
    @Binding var code: String
    @Binding var points: Int
    
    @State private var pending: Bool = false
    let apiManager = APIManager()
    
    var body: some View {
        VStack {
            Text("Create a Referral Code")
                .font(.title)
            Text("This will create your personal referral code on our server. It will be stored on our server to calculate and reward your referrals.")
            // check mark
            Button {
                let secret = ReferralCodeManager.shared.getSecretCode()
                pending = true
                apiManager.createUser(secret: secret) { response in
                    switch response {
                    case .success(let createdUser):
                        ReferralCodeManager.shared.setReferralCode(createdUser.referral_code)
                        code = createdUser.referral_code
                        points = createdUser.points
                    case .failure(let error):
                        print(error)
                    }
                    pending = false
                }
            } label: {
                if pending {
                    ProgressView()
                } else {
                    Text("Continue")
                }
            }
        }
    }
}
