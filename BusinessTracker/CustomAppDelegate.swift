//
//  CustomAppDelegate.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-22.
//

import UIKit
import GoogleMobileAds

class CustomAppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "70c20d4bb5f0a13a78a7b8ac37f7cf16" ]
        return true
    }
}
