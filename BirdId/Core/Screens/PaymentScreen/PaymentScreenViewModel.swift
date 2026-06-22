//
//  SubscriptionViewModel.swift
//  LogoGenerator
//
//  Created by Ali Movahedzade on 5/19/26.
//

import Foundation
import RevenueCat
import Combine


class SubscriptionViewModel: ObservableObject {
    @Published var offerings: Offerings?
    @Published var selectedPackage: Package?
    @Published var isProUser = false
    @Published var freeTrial = false
    @Published var purchaseStatus: String = ""
    @Published var isLoding = false
    @Published var isFreeTrialEnabled = false
    init() {
        fetchOfferings()
        checkSubscriptionStatus()
    }

    func fetchOfferings() {
        Purchases.shared.getOfferings { offerings, error in
            DispatchQueue.main.async {
                if let offerings = offerings {
                    self.offerings = offerings
                    print(offerings)
                    self.selectedPackage = offerings.current?.availablePackages.first
                } else if let error = error {
                    print("❌ Error fetching offerings: \(error.localizedDescription)")
                }
            }
        }
    }

    func purchaseSelectedPackage(
        callback: @escaping (_ customerInfo: CustomerInfo?) -> Void
    ) {
        guard let package = selectedPackage else {
            purchaseStatus = "No package selected."
            return
        }

        Purchases.shared.purchase(package: package) { [weak self] _, customerInfo, error, userCancelled in
            guard let self = self else { return }

            if let error = error {
                self.purchaseStatus = "Purchase failed: \(error.localizedDescription)"
                callback(nil)
                return
            }

            if userCancelled {
                self.purchaseStatus = "Purchase cancelled."
                callback(nil)
                return
            }

            callback(customerInfo)
        }
    }
    
    
    func restorePurchases() {
        Purchases.shared.restorePurchases { customerInfo, error in
            if customerInfo?.entitlements.active.keys.contains("pro") == true {
                DispatchQueue.main.async {
                    self.purchaseStatus = "Purchase restored!"
                    self.isProUser = true
                }
            } else {
                self.purchaseStatus = "No purchases to restore."
            }
        }
    }

    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            DispatchQueue.main.async {
                self.isProUser = customerInfo?.entitlements.active.keys.contains("pro") == true

//                if let customerInfo = customerInfo {
//                    Task {
//                        await sendPurchaseToBackend(deviceID: "deviceID", customerInfo: customerInfo)
//                    }
//                }
            }
        }
    }
}
