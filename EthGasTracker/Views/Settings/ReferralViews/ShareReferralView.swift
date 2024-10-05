//
//  ReferralSheetView.swift
//  EthGasTracker
//
//  Created by Tem on 9/29/24.
//


import SwiftUI
import UIKit

struct ReferralCodeActionsView: View {
    let userReferralCode: String
    @State private var showShareSheet = false
    let appStoreLink = "https://apps.apple.com/us/app/gas-alert-ethereum-gas-tracker/id6446234870" // Replace with your App Store link
    
    var referralMessage: String {
        return "get Gas Alert app: \(appStoreLink), enter my code: \(userReferralCode) and we both get Plus features"
    }
    
    var body: some View {
        
        // Share Button
        Button(action: {
            //shareReferralLink()
            showShareSheet = true
        }) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text(userReferralCode)
                    .bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [referralMessage])
                .presentationDetents([.medium, .large])
        }
        
        // Copy to Clipboard Button
        Button(action: {
            copyReferralLinkToClipboard()
        }) {
            HStack {
                Image(systemName: "doc.on.doc")
                Text("Copy to Clipboard")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
    }
    
    private func copyReferralLinkToClipboard() {
        UIPasteboard.general.string = referralMessage
        print("Referral link copied to clipboard!")
    }
}

struct ShareReferralView: View {
    let userReferralCode: String
    
    var body: some View {
        VStack(spacing: 10) {
            // Title
            Text("Invite Friends to unlock Plus features")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            
            // Short Explanation
            Text("When a friend downloads the app and enters your referral code, you get a point. Collect points and redeem them for access to Plus features.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
            
            ReferralCodeActionsView(userReferralCode: userReferralCode)
        }
    }
    
//    // Function to share referral link
//    private func shareReferralLink() {
//        let activityController = UIActivityViewController(activityItems: [referralMessage], applicationActivities: nil)
//        
//        if let topController = UIApplication.shared.windows.first?.rootViewController {
//            topController.present(activityController, animated: true, completion: nil)
//        }
//    }
    
    // Function to copy referral link to clipboard
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}

struct ReferralSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ShareReferralView(userReferralCode: "ABC123")
    }
}
