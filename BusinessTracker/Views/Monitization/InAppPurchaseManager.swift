//
//  InAppPurchaseManager.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-23.
//

import Foundation
import StoreKit

func isSubscriptionActive() -> Bool {
    // Check if the subscription is still active
    if let expiryDate = UserDefaults.standard.object(forKey: "subscriptionExpiryDate") as? Date {
        return Date() < expiryDate
    }
    return false
}

class InAppPurchaseManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = InAppPurchaseManager()
    @Published private(set) var subscriptionProduct: SKProduct?
    
    override init() {
        super.init()
        requestProducts()
    }
    
    func requestProducts() {
        let productIdentifiers = Set(["ca.icubemedia.bet"])
        let productRequest  = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            subscriptionProduct = product
        } else {
            print("No products found")
        }

        if !response.invalidProductIdentifiers.isEmpty {
            print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
        }
    }

    
    func purchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        guard let userId = getCurrentUserId() else {
            print("User ID not found")
            return
        }

        guard let token = getToken() else {
            print("Token not found")
            return
        }
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                UserDefaults.standard.set("paid", forKey: "accountType")
                UserServie().updateUserAccountType(userId: userId, authToken: token, accountType: "paid") { result in
                    switch result {
                    case .success(let message):
                        print(message)
                    case .failure(let error):
                        print("Error updating user account type: \(error.localizedDescription)")
                    }
                }
                if let expiryDate = transaction.subscriptionExpiryDate {
                    // Save the expiry date and other relevant data
                    UserDefaults.standard.set(expiryDate, forKey: "subscriptionExpiryDate")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed, .deferred:
                // Handle the error or defer the transaction
                SKPaymentQueue.default().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
}

extension SKPaymentTransaction {
    var subscriptionExpiryDate: Date? {
        return self.transactionDate?.addingTimeInterval(self.subscriptionPeriod)
    }
    
    var subscriptionPeriod: TimeInterval {
        let productIdentifier = self.payment.productIdentifier
        if let product = InAppPurchaseManager.shared.subscriptionProduct,
           product.productIdentifier == productIdentifier,
           let subscriptionPeriod = product.subscriptionPeriod {
            return subscriptionPeriod.inSeconds()
        } else {
            return 0
        }
    }
}

extension SKProductSubscriptionPeriod {
    func inSeconds() -> TimeInterval {
        var timeInterval: TimeInterval = 0
        switch self.unit {
        case .day:
            timeInterval = 86400
        case .week:
            timeInterval = 604800
        case .month:
            timeInterval = 2592000
        case .year:
            timeInterval = 31536000
        @unknown default:
            fatalError("Unknown subscription period unit")
        }
        return timeInterval * Double(self.numberOfUnits)
    }
}
