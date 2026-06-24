//
//  SubscriptionManager.swift
//  BirdId
//
//  Created by Ali Movahedzade on 6/7/26.
//

import Foundation
import RevenueCat
import Combine
import UIKit

@MainActor
class SubscriptionManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    // MARK: - Singleton
    static let shared = SubscriptionManager()
    
    // Update these to match your RevenueCat entitlement identifiers
    private let entitlementIdentifiers = ["premium", "Pro", "premium_access", "premium access"]
    
    // MARK: - Initialization
    private init() {
        configureRevenueCat()
        loadSubscriptionStatus()
    }
    
    // MARK: - Configuration
    private func configureRevenueCat() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_TNoJmWSwGQEQoShMmREpTQTnmmh")
        
    }
    
    // MARK: - Subscription Status Checking
    func loadSubscriptionStatus() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                await updateSubscriptionStatus(customerInfo: customerInfo)
                isLoading = false
                print("✅ Initial subscription status loaded: \(isPremium ? "Premium" : "Not Premium")")
            } catch {
                await MainActor.run {
                    self.error = "Failed to load subscription status: \(error.localizedDescription)"
                    self.isLoading = false
                }
                print("❌ Failed to load subscription status: \(error)")
            }
        }
    }
    
    
    func debugRevenueCatData() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                print("=== 🚨 REVENUECAT COMPLETE DEBUG ===")
                
                // Basic user info
                print("📱 User ID: \(customerInfo.originalAppUserId)")
                print("📅 First Seen: \(customerInfo.firstSeen)")
                print("⏰ Latest Expiration: \(String(describing: customerInfo.latestExpirationDate))")
                
                // All active entitlements (regardless of names)
                print("\n🔍 ALL ACTIVE ENTITLEMENTS:")
                if customerInfo.entitlements.active.isEmpty {
                    print("   ❌ NO ACTIVE ENTITLEMENTS FOUND")
                } else {
                    for (key, entitlement) in customerInfo.entitlements.active {
                        print("   ✅ '\(key)':")
                        print("      - Product: \(entitlement.productIdentifier ?? "none")")
                        print("      - Expires: \(entitlement.expirationDate?.description ?? "never")")
                        print("      - Will Renew: \(entitlement.willRenew)")
                        print("      - Period Type: \(entitlement.periodType)")
                    }
                }
                
                // All entitlements (active + inactive)
                print("\n📋 ALL ENTITLEMENTS (ACTIVE + INACTIVE):")
                if customerInfo.entitlements.all.isEmpty {
                    print("   ❌ NO ENTITLEMENTS FOUND AT ALL")
                } else {
                    for (key, entitlement) in customerInfo.entitlements.all {
                        let status = entitlement.isActive ? "✅ ACTIVE" : "❌ INACTIVE"
                        print("   \(status) '\(key)':")
                        print("      - Product: \(entitlement.productIdentifier ?? "none")")
                        print("      - Expires: \(entitlement.expirationDate?.description ?? "never")")
                        print("      - Is Active: \(entitlement.isActive)")
                    }
                }
                
                // All active subscriptions (CORRECTED API)
                print("\n💳 ALL ACTIVE SUBSCRIPTIONS:")
                let activeSubscriptions = customerInfo.activeSubscriptions
                if activeSubscriptions.isEmpty {
                    print("   ❌ NO ACTIVE SUBSCRIPTIONS")
                } else {
                    for productId in activeSubscriptions {
                        print("   📦 \(productId)")
                    }
                }
                
                // Non-subscription purchases (CORRECTED API)
                print("\n🛍️ NON-SUBSCRIPTION PURCHASES:")
                let nonSubscriptions = customerInfo.nonSubscriptions
                if nonSubscriptions.isEmpty {
                    print("   ❌ NO NON-SUBSCRIPTION PURCHASES")
                } else {
                    for productId in nonSubscriptions {
                        print("   🎯 \(productId)")
                    }
                }
                
                print("=== 🚨 END DEBUG ===")
                
            } catch {
                print("❌ Debug failed: \(error)")
            }
        }
    }
    
    
    func updateFromCustomerInfo(_ customerInfo: CustomerInfo) {
        updateSubscriptionStatus(customerInfo: customerInfo)
    }
    
    
    
    private func loadSubscriptionStatusWithRestore() {
        isLoading = true
        error = nil
        
        Task {
            do {
                // First try to get current customer info
                let customerInfo = try await Purchases.shared.customerInfo()
                
                // If no active entitlements found, try restoring
                var hasActiveEntitlement = false
                for identifier in entitlementIdentifiers {
                    if let entitlement = customerInfo.entitlements[identifier], entitlement.isActive {
                        hasActiveEntitlement = true
                        break
                    }
                }
                
                if !hasActiveEntitlement {
                    print("🔄 No active entitlements found, attempting restore...")
                    let restoredCustomerInfo = try await Purchases.shared.restorePurchases()
                    await updateSubscriptionStatus(customerInfo: restoredCustomerInfo)
                } else {
                    await updateSubscriptionStatus(customerInfo: customerInfo)
                }
                
                isLoading = false
                print("✅ Subscription status loaded: \(isPremium ? "Premium" : "Not Premium")")
                
            } catch {
                await MainActor.run {
                    self.error = "Failed to load subscription status: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    
    private func updateSubscriptionStatus(customerInfo: CustomerInfo) {
        // Check all entitlement identifiers
        for identifier in entitlementIdentifiers {
            if let entitlement = customerInfo.entitlements[identifier], entitlement.isActive {
                isPremium = true
                print("✅ Found active entitlement: \(identifier)")
                return
            }
        }
        
        // If no active entitlements found
        isPremium = false
        print("❌ No active entitlements found")
    }
    
    // MARK: - Simple Premium Check
    func checkIsUserPremium() -> Bool {
        return isPremium
    }
    
    func getPremiumStatus() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            
            for identifier in entitlementIdentifiers {
                if let entitlement = customerInfo.entitlements[identifier], entitlement.isActive {
                    await MainActor.run {
                        self.isPremium = true
                    }
                    return true
                }
            }
            
            await MainActor.run {
                self.isPremium = false
            }
            return false
            
        } catch {
            await MainActor.run {
                self.error = "Failed to get premium status: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - Debug
    func debugPrintCurrentStatus() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                print("🔍 Current Entitlements:")
                for identifier in entitlementIdentifiers {
                    if let entitlement = customerInfo.entitlements[identifier] {
                        print("   - \(identifier): isActive=\(entitlement.isActive)")
                    } else {
                        print("   - \(identifier): Not found")
                    }
                }
                print("   - Final isPremium: \(isPremium)")
            } catch {
                print("❌ Error getting customer info: \(error)")
            }
        }
    }
    
    private func setupRestoreOnAppStart() {
        // Restore purchases when app becomes active
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.restorePurchasesSilently()
        }
    }
    
    private func restorePurchasesSilently() {
           Task {
               do {
                   let customerInfo = try await Purchases.shared.restorePurchases()
                   await updateSubscriptionStatus(customerInfo: customerInfo)
                   print("🔄 Silently restored purchases - isPremium: \(isPremium)")
               } catch {
                   print("❌ Silent restore failed: \(error)")
               }
           }
       }
}

