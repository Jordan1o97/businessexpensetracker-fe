//
//  CustomAppDelegate.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-22.
//

import UIKit
import GoogleMobileAds
import Firebase

class CustomAppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
}
