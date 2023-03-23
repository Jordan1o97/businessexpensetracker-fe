//
//  InterstitialAdController.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-22.
//

import SwiftUI
import GoogleMobileAds

class InterstitialAdController: NSObject, GADFullScreenContentDelegate {
    private var interstitialAd: GADInterstitialAd?
    var onAdDismissed: (() -> Void)?

    override init() {
        super.init()
        loadInterstitialAd()
    }

    func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-9324761796430059/6793125518", request: request) { [weak self] (ad, error) in
            if let error = error {
                print("Loading failed: \(error.localizedDescription)")
            } else {
                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
            }
        }
    }

    func showAd(from rootController: UIViewController) {
        if let ad = interstitialAd {
            ad.present(fromRootViewController: rootController)
        } else {
            print("Ad was not ready")
            onAdDismissed?()
            loadInterstitialAd()
        }
    }

    // MARK: - GADFullScreenContentDelegate

    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content")
        onAdDismissed?()
        loadInterstitialAd()
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present full screen content with error: \(error.localizedDescription)")
        onAdDismissed?()
        loadInterstitialAd()
    }
}
