//
//  SubscriptionManager.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-23.
//

import Foundation
import Combine

class SubscriptionManager: ObservableObject {
    var checkSubscriptionTimer: Timer?

    func startCheckingSubscription() {
        checkSubscriptionTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            self.checkSubscriptionStatus()
        }
    }

    func stopCheckingSubscription() {
        checkSubscriptionTimer?.invalidate()
        checkSubscriptionTimer = nil
    }

    @objc private func checkSubscriptionStatus() {
        guard let userId = getCurrentUserId() else {
            print("User ID not found")
            return
        }

        guard let token = getToken() else {
            print("Token not found")
            return
        }
        // Check if the subscription is active
        if !isSubscriptionActive() {
            UserDefaults.standard.set("free", forKey: "accountType")
            UserServie().updateUserAccountType(userId: userId, authToken: token, accountType: "free") { result in
                switch result {
                case .success(let message):
                    print(message)
                case .failure(let error):
                    print("Error updating user account type: \(error.localizedDescription)")
                }
            }
        }
    }
}
