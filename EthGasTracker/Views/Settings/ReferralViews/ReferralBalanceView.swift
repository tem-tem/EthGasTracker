//
//  ReferralBalanceView.swift
//  EthGasTracker
//
//  Created by Tem on 10/3/24.
//

import SwiftUI

struct ReferralBalanceView: View {
    @EnvironmentObject var alertToastManager: AlertToastManager
    @State private var showReferralSheet = false
    @State private var userReferralCode = ReferralCodeManager.shared.getReferralCode()
    @AppStorage("points") var points: Int = 0
    
    @State private var showingRefresh = true
    @State private var showingSuccessIcon = false
    @State private var showingErrorIcon = false
    @State private var pending = false
    
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert = false
    
    @State private var showRedeemSheet = false
    
    let primary = Color.primary
    
    let apiManager = APIManager()
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("\(points)")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    if showingRefresh {
                        Button {
                            let referralPointsRequest = ReferralPointsRequest(referralCode: userReferralCode ?? "", secret: ReferralCodeManager.shared.getSecretCode())
                            
                            withAnimation {
                                showingRefresh = false
                            }
                            apiManager.getReferralPoints(requestBody: referralPointsRequest) { response in
                                switch response {
                                case .success(let pointsResponse):
                                    DispatchQueue.main.async {
                                        points = pointsResponse.points
                                        // showingRefresh = true after 10 seconds
                                        showingSuccessIcon = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                            withAnimation {
                                                showingRefresh = true
                                            }
                                        }
                                    }
                                case .failure(let error):
                                    print(error)
                                    showingErrorIcon = true
                                    //                                alertToastManager.showError(error.localizedDescription)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.borderless)
                        .transition(.scale)
                    } else {
                        if showingSuccessIcon {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .transition(.scale)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            showingSuccessIcon = false
                                        }
                                    }
                                }
                        } else if showingErrorIcon {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                                .transition(.scale)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            showingErrorIcon = false
                                        }
                                    }
                                }
                        }
                    }
                }
                HStack {
                    Text("Reward Points")
                    
                    Button {
                        showRedeemSheet = true
                    } label: {
                        HStack {
                            Text("Redeem")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                        .foregroundColor(.white)
                    }
                    .sheet(isPresented: $showRedeemSheet) {
                        ReferralRedeemView() {
                            showRedeemSheet = false
                            alertToastManager.showSuccess("Gas Plus Activated")
                        }
                            .presentationDetents([.medium])
                    }
                    .buttonStyle(.borderless)
                    
                    Spacer()
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            
            Text("Points can be used to unlock Plus features. Invite Friends to get more points.")
                .font(.caption)
        }
    }
}

#Preview {
    PreviewWrapper {
        ReferralBalanceView()
    }
}
