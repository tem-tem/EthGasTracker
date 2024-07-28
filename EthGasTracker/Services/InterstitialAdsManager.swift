//
//  InterstitialAdsManager.swift
//  EthGasTracker
//
//  Created by Tem on 7/25/24.
//

import Foundation
import GoogleMobileAds

class InterstitialAdsManager: NSObject, GADFullScreenContentDelegate, ObservableObject {
    
    // Properties
    @Published var interstitialAdLoaded:Bool = false
    @Published var lastShownTimestamp = Date(timeIntervalSince1970: 0)
    @Published var loading = false
    var interstitialAd:GADInterstitialAd?
    
    override init() {
        super.init()
    }
    
    // Load InterstitialAd
    func loadInterstitialAd(){
        loading = true
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3688862820581365/3298470079", request: GADRequest()) { [weak self] add, error in
            guard let self = self else {return}
            if let error = error{
                print("🔴: \(error.localizedDescription)")
                self.interstitialAdLoaded = false
                return
            }
            print("🟢: Loading succeeded")
            self.interstitialAdLoaded = true
            self.interstitialAd = add
            self.loading = false
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }
    
    // Display InterstitialAd
    func displayInterstitialAd(){
        guard let root = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        if let add = interstitialAd{
            add.present(fromRootViewController: root)
//            self.interstitialAdLoaded = false
        }else{
            print("🔵: Ad wasn't ready")
            self.interstitialAdLoaded = false
            self.loadInterstitialAd()
        }
    }
    
    // Failure notification
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("🟡: Failed to display interstitial ad")
        self.loadInterstitialAd()
    }
    
    // Indicate notification
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("🤩: Displayed an interstitial ad")
    }
    
    // Close notification
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("😔: Interstitial ad closed")
        lastShownTimestamp = Date()
        self.interstitialAdLoaded = false
    }
}
