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
        SKPaymentQueue.default().add(self)
    }
    
    func requestProducts() {
        let productIdentifiers = Set(["ca.icubemedia.bet"])
        let productRequest  = SKProductsRequest(productIdentifiers: productIdentifiers)
        print(productRequest)
        productRequest.delegate = self
        productRequest.start()
        print("⚠️", "Requesting Purchases")
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first{
            self.subscriptionProduct = product
            print("⚠️", "\(self.subscriptionProduct ) Product in question")
        } else {
            print("No products found")
        }
        
        if !response.invalidProductIdentifiers.isEmpty {
            print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
        }
    }
    
    
    func purchase(product: SKProduct) {
        clearTransactionQueue()
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        print("⚠️", "Adding to queue: \(product)")
    }
    
    func clearTransactionQueue() {
        for transaction in SKPaymentQueue.default().transactions {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("⚠️", "App is in Queue")
        guard let userId = getCurrentUserId() else {
            print("User ID not found")
            return
        }
        
        guard let token = getToken() else {
            print("Token not found")
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    // Extract receipt data
                    guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                          FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
                        // Handle missing receipt
                        print("Missing receipt")
                        continue
                    }
                    
                    do {
                        print("⚠️", "App is about to send api")
                        let receiptData = try Data(contentsOf: appStoreReceiptURL)
                        // Send receipt data to your server for validation
                        UserServie().validateReceipt(receiptData: receiptData) { result in
                            DispatchQueue.global(qos: .background).async { 
                                switch result {
                                case .success(let expiryDate):
                                    // Handle the result of the validation
                                    print("Validation successful. Expiry date: \(expiryDate?.description ?? "N/A")")
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
                                    queue.finishTransaction(transaction)
                                case .failure(let error):
                                    print("Error validating receipt: \(error.localizedDescription)")
                                    // Handle the error accordingly
                                }
                            }
                        }
                    } catch {
                        // Handle error reading receipt data
                        print("Error reading receipt data: \(error.localizedDescription)")
                    }
                    
                case .failed:
                    print("Transaction failed: \(transaction.error?.localizedDescription ?? "unknown error")")
                    queue.finishTransaction(transaction)
                    
                case .deferred, .purchasing:
                    break
                    
                @unknown default:
                    fatalError("Unknown transaction state encountered")
                }
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
