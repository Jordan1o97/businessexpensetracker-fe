//
//  AdButton.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-22.
//

import SwiftUI

struct AdButton<Content: View>: View {
    var onButtonAction: () -> Void
    let content: () -> Content
    let probabilityToShowAd = 0.3

    @State private var adController = InterstitialAdController()
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")

    init(onButtonAction: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.onButtonAction = onButtonAction
        self.content = content
    }

    var body: some View {
        Button(action: {
            let randomNumber = Double.random(in: 0...1)
            if accountType == "free" && randomNumber <= probabilityToShowAd {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    if let rootController = scene.windows.first?.rootViewController {
                        adController.onAdDismissed = {
                            // Execute the original button function after the ad is dismissed
                            onButtonAction()
                        }
                        adController.showAd(from: rootController)
                    }
                }
            } else {
                // Execute the original button function without showing the ad
                onButtonAction()
            }
        }) {
            content()
        }
    }
}

