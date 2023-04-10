//
//  CustomAppDelegate.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-22.
//

import UIKit
import Firebase
import GoogleMobileAds

class CustomAppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        DispatchQueue.global(qos: .background).async {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
        
        return true
    }
}
