//
//  File.swift
//  ExpenseLog
//
//  Created by Tem on 9/23/23.
//

import Foundation
import SwiftUI
import StoreKit

//alias
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo //The Product.SubscriptionInfo.RenewalInfo provides information about the next subscription renewal period.
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState // the renewal states of auto-renewable subscriptions.


class StoreVM: ObservableObject {
    @Published private(set) var checked: Bool = false
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    
    /// The subscription status - persisted and used as source of truth throughout the app
    @AppStorage("subbed") var subbed: Bool = false
    
    /// The original transaction identifier for the active subscription
    /// This ID is unique per user across all devices and persists for the lifetime of the subscription
    /// Perfect for server-side subscription validation and cleanup
    /// Persisted to survive app restarts
    @AppStorage("subscriptionIdentifier") var subscriptionIdentifier: String?
    
    private let productIds: [String] = ["weekly_001", "yearly_001", "monthly_001"]
    
    var updateListenerTask : Task<Void, Error>? = nil

    init() {
        
        //start a transaction listern as close to app launch as possible so you don't miss a transaction
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    // deliver products to the user
                    await self.updateCustomerProductStatus()
                    
                    await transaction.finish()
                } catch {
                    print("transaction failed verification")
                }
            }
        }
    }
    
    
    
    // Request the products
    @MainActor
    func requestProducts() async {
        do {
            // request from the app store using the product ids (hardcoded)
            subscriptions = try await Product.products(for: productIds)
            print(subscriptions)
        } catch {
            print("Failed product request from app store server: \(error)")
        }
    }
    
    // purchase the product
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            //Check whether the transaction is verified. If it isn't,
            //this function rethrows the verification error.
            let transaction = try checkVerified(verification)
            
            //The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()
            
            //Always finish a transaction.
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        checked = false
        purchasedSubscriptions = []
        
        // Clear subscription state by default (will be set if active subscription found)
        var foundSubscriptionID: String?
        var hasActiveSubscription = false
        
        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                //Check whether the transaction is verified. If it isn't, catch `failedVerification` error.
                let transaction = try checkVerified(result)
                
                switch transaction.productType {
                    case .autoRenewable:
                        if let subscription = subscriptions.first(where: {$0.id == transaction.productID}) {
                            purchasedSubscriptions.append(subscription)
                            hasActiveSubscription = true
                            
                            // Store the original transaction identifier (unique per user across devices)
                            // This is stable and persists for the lifetime of the subscription
                            if foundSubscriptionID == nil {
                                foundSubscriptionID = String(transaction.originalID)
                                print("📱 Subscription ID: \(transaction.originalID)")
                            }
                        }
                    default:
                        break
                }
                //Always finish a transaction.
                await transaction.finish()
            } catch {
                print("failed updating products")
            }
        }
        
        // Update global subscription state (source of truth)
        subbed = hasActiveSubscription
        subscriptionIdentifier = foundSubscriptionID
        
        if hasActiveSubscription {
            print("✅ Subscription active: subbed=\(subbed), ID=\(subscriptionIdentifier ?? "nil")")
        } else {
            print("❌ No active subscription: subbed=\(subbed), ID=\(subscriptionIdentifier ?? "nil")")
        }
        
        checked = true
    }

}


public enum StoreError: Error {
    case failedVerification
}
