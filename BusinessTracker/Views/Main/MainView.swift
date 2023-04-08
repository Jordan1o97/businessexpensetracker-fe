//
//  MainView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-15.
//

import SwiftUI

struct MainView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isPresentingScanner = true
    @State private var selectedView: ViewType = .receipts
    @State private var showSubscriptionPrompt = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                colorScheme == .dark ? Color(.systemGray5) : Color.white
                VStack {
                    Spacer()
                    getView(for: selectedView)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    
                    BottomBarView(activeTab: $selectedView)
                        .background(colorScheme == .dark ? Color(.systemGray5) : Color.white)
                }
            }.edgesIgnoringSafeArea(.all)
        }
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if UserDefaults.standard.bool(forKey: "subscriptionPromptShown") == false {
                showSubscriptionPrompt = true
                UserDefaults.standard.set(true, forKey: "subscriptionPromptShown")
            }
        }
        .fullScreenCover(isPresented: $showSubscriptionPrompt) {
            SubscriptionPromptView(isPresented: $showSubscriptionPrompt);
        }
    }
    
    private func getView(for viewType: ViewType) -> some View {
        switch viewType {
        case .receipts:
            return AnyView(ReceiptMainView())
        case .triplog:
            return AnyView(TripLogMainView())
        case .timesheet:
            return AnyView(TimeTrackerMainView())
        case .settings:
            return AnyView(SettingsView())
        }

        // Default view
        return AnyView(ScannerView(result: .constant("TempView")))
    }
    func logout() {
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.set(false, forKey: "rememberMe")
        // Implement navigation to the login screen or any other required action
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white
            VStack {
                Spacer()
                TimeTrackerMainView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                
                BottomBarView(activeTab: .constant(.timesheet))
                    .background(Color.white)
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
