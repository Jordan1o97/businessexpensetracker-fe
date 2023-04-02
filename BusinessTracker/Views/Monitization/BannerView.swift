//
//  BannerView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-22.
//

import SwiftUI
import GoogleMobileAds

struct BannerView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 25)))
        DispatchQueue.global(qos: .background).async {
            bannerView.adUnitID = adUnitID
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                bannerView.rootViewController = windowScene.windows.first?.rootViewController
            }
            bannerView.load(GADRequest())
        }
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
    }
}
