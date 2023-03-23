//
//  BusinessTrackerApp.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-07.
//

import SwiftUI

enum ViewType {
    case receipts, triplog, timesheet, settings
}

@main
struct BusinessTrackerApp: App {
    @UIApplicationDelegateAdaptor(CustomAppDelegate.self) var appDelegate
    @State private var showSignIn = UserDefaults.standard.bool(forKey: "rememberMe")
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    var body: some Scene {
        WindowGroup {
            if showSignIn {
                MainView()
                    .onAppear {
                        subscriptionManager.startCheckingSubscription()
                    }
            } else {
                SignInView()
            }
        }
    }
}

struct BusinessTrackerApp_Previews: PreviewProvider {
    static var previews: some View {
        return SignInView()
    }
}
