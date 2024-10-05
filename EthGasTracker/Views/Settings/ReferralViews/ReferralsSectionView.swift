//
//  PlusSectionView.swift
//  EthGasTracker
//
//  Created by Tem on 9/29/24.
//

import SwiftUI
import AlertToast

struct ReferralsSectionView: View {
    @EnvironmentObject var alertToastManager: AlertToastManager
    var showingDebugControls: Bool = false
    @State private var showReferralSheet = false
    @State private var userReferralCode = ReferralCodeManager.shared.getReferralCode()
    @AppStorage("points") var points: Int = 0
    @AppStorage("wasReferred") var wasReferred: Bool = false
    
    @State private var showCodeInput = false
    @State private var inputCode: String = ""
    @State private var pending = false
    
//    @State private var errorMessage: String? = nil
//    @State private var showErrorAlert = false
    @State private var showInputAlert = false
    @State private var showAlert = false
    
//    @State private var showSuccessAlert = false
    
    let primary = Color.primary
    
    let apiManager = APIManager()
    
    var body: some View {
        VStack(alignment: .leading) {
            if !wasReferred {
                Button {
                    if userReferralCode != nil {
                        showInputAlert = true // Show the alert for code input
                    } else {
                        let secret = ReferralCodeManager.shared.getSecretCode()
                        pending = true
                        apiManager.createUser(secret: secret) { response in
                            switch response {
                            case .success(let createdUser):
                                ReferralCodeManager.shared.setReferralCode(createdUser.referralCode)
                                userReferralCode = createdUser.referralCode
                                points = createdUser.points
                                showInputAlert = true
                            case .failure(let error):
                                print(error)
                                
                                alertToastManager.showError(error.localizedDescription)
                            }
                            pending = false
                        }
                    }
                } label: {
                    HStack {
                        if pending {
                            ProgressView()
                                .frame(width: 32, height: 32)
                        } else {
                            Image(systemName: "person.2.fill")
                                .frame(width: 32, height: 32)
                                .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                        }
                        Text("Enter Referral Code")
                            .foregroundStyle(primary)
                    }
                }
                .buttonStyle(.borderless)
            }
            
            Button {
                if userReferralCode != nil {
                    showReferralSheet = true
                } else {
                    let secret = ReferralCodeManager.shared.getSecretCode()
                    pending = true
                    apiManager.createUser(secret: secret) { response in
                        switch response {
                        case .success(let createdUser):
                            ReferralCodeManager.shared.setReferralCode(createdUser.referralCode)
                            userReferralCode = createdUser.referralCode
                            points = createdUser.points
                            showReferralSheet = true
                        case .failure(let error):
                            print(error)
                            alertToastManager.showError(error.localizedDescription)
                        }
                        pending = false
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "gift")
                        .frame(width: 32, height: 32)
                        .background(.red, in: RoundedRectangle(cornerRadius: 8))
                        .foregroundColor(.white)
                    
                    Text("Invite Friends")
                        .foregroundStyle(primary)
                }
            }
            .sheet(isPresented: $showReferralSheet) {
                if let code = userReferralCode {
                    ShareReferralView(userReferralCode: code)
                        .presentationDetents([.medium])
                }
            }
            .buttonStyle(.borderless)
            
            #if DEBUG
            if showingDebugControls {
                VStack(alignment: .leading) {
                    HStack { Spacer() }
                    Text("Referral code: \(userReferralCode ?? "No code")")
                    Text("Points: \(points)")
                    if PlusFeatureManager.shared.hasPremiumAccess() {
                        Text("Expiration: \(PlusFeatureManager.shared.getPremiumExpirationDate() ?? Date())")
                    }
                    Button {
                        ReferralCodeManager.shared.clearReferralCode()
                        PlusFeatureManager.shared.clearPremiumAccess()
                        userReferralCode = nil
                        print("Referral code cleared")
                    } label: {
                        HStack {
                            Image(systemName: "xmark")
                                .frame(width: 32, height: 32)
                                .background(.red, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            Text("Clear Referral Code")
                                .foregroundStyle(primary)
                        }
                    }
                    .buttonStyle(.borderless)
                    Button {
                        let referralPointsRequest = ReferralPointsRequest(referralCode: userReferralCode ?? "", secret: ReferralCodeManager.shared.getSecretCode())
                        apiManager.getReferralPoints(requestBody: referralPointsRequest) { response in
                            switch response {
                            case .success(let pointsResponse):
                                DispatchQueue.main.async {
                                    points = pointsResponse.points
                                }
                            case .failure(let error):
                                print(error)
                                alertToastManager.showError(error.localizedDescription)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .frame(width: 32, height: 32)
                                .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            Text("Check Points")
                                .foregroundStyle(primary)
                        }
                    }
                    .buttonStyle(.borderless)
                    
                    Button {
                        alertToastManager.showSuccess("Test Success Alert")
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                                .frame(width: 32, height: 32)
                                .background(.green, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            Text("Test Success Alert")
                                .foregroundStyle(primary)
                        }
                    }
                    .buttonStyle(.borderless)
                    
                    Button {
                        alertToastManager.showError("Test Error Alert")
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .frame(width: 32, height: 32)
                                .background(.red, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            Text("Test Error Alert")
                                .foregroundStyle(primary)
                        }
                    }
                    
                    Button {
                        PlusFeatureManager.shared.setPremiumExpirationDate(Date())
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                                .frame(width: 32, height: 32)
                                .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.white)
                            Text("Set Premium Expiration")
                                .foregroundStyle(primary)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [10]))
                )
                .padding()
            }
            #endif
        }
        .sheet(isPresented: $showInputAlert) {
            ReferralInputSheet(inputCode: $inputCode) {
                guard let referral = userReferralCode else {
                    return
                }
                let referralData: ReferralRequest = .init(ownerReferralCode: inputCode, inviteeReferralCode: referral, secret: ReferralCodeManager.shared.getSecretCode())
                apiManager.applyReferral(requestBody: referralData) { response in
                    switch response {
                    case .success:
                        print("Referral applied successfully: \(response)")
                        alertToastManager.showSuccess("Sent for approval")
                        showInputAlert = false
                    case .failure(let error):
                        print("Error applying referral: \(error.localizedDescription)")
                        alertToastManager.showError(error.localizedDescription, displayMode: .hud)
                    }
                }
            } onCancel: {
                showInputAlert = false
            }
            .presentationDetents([.fraction(0.3)])
        }
//        .toast(isPresenting: $showErrorAlert, duration: 4, tapToDismiss: true, alert: {
//            AlertToast(displayMode: .hud, type: .error(.red), title: errorMessage ?? "An error occurred")
//        })
//        .toast(isPresenting: $showSuccessAlert, duration: 4, tapToDismiss: true, alert: {
//            AlertToast(displayMode: .hud, type: .complete(Color.green), title: "Sent for approval")
//        })

    }
}


#Preview {
    PreviewWrapper {
        ReferralsSectionView(showingDebugControls: true)
    }
}
