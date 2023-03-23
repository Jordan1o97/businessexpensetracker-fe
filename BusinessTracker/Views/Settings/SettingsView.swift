//
//  SettingsView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-20.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showCategoryManager = false
    @State private var showClientManager = false
    @State private var showVehicleManager = false
    @State private var showEditProfile = false
    @State private var showSignIn = false
    @ObservedObject private var iapManager = InAppPurchaseManager.shared
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    @StateObject private var subscriptionManager = SubscriptionManager()

    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all) // Set the background grey color
            
            VStack {
                if(accountType == "free"){
                    BannerView(adUnitID: "ca-app-pub-9324761796430059/9535673072")
                        .frame(maxHeight: 50)
                        .padding(.top, 50)
                }
                HStack {
                    Text("Settings")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
                
                
                VStack {
                    VStack(){
                        AdButton(onButtonAction: {
                            showCategoryManager.toggle()
                        }) {
                            SettingButton(title: "Category Manager")
                        }
                        .sheet(isPresented: $showCategoryManager) {
                            CategorySettingView(isPresented: $showCategoryManager)
                        }
                        
                        AdButton(onButtonAction: {
                            showClientManager.toggle()
                        }) {
                            SettingButton(title: "Client Manager")
                        }
                        .sheet(isPresented: $showClientManager) {
                            ClientSettingView(isPresented: $showClientManager)
                        }
                        
                        AdButton(onButtonAction: {
                            showVehicleManager.toggle()
                        }) {
                            SettingButton(title: "Vehicle Manager")
                        }
                        .sheet(isPresented: $showVehicleManager) {
                            VehicleSettingView(isPresented: $showVehicleManager)
                        }
                    }.padding(.bottom, 50)
                    VStack(){
                        Button(action: {
                            disableAds()
                        }) {
                            SettingButton(title: "Disable Ads")
                        }
                        .sheet(isPresented: $showEditProfile) {
                            EditProfileView()
                        }
                        
                        Button(action: {
                            logout()
                            showSignIn = true;
                        }) {
                            LogoutButton(title: "Logout")
                                
                        }
                        .fullScreenCover(isPresented: $showSignIn) {
                            SignInView()
                        }
                    }
                    BannerContainerView()
                }
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.set(false, forKey: "rememberMe")
        subscriptionManager.stopCheckingSubscription()
    }
    
    private func disableAds() {
        if let product = iapManager.subscriptionProduct {
            iapManager.purchase(product: product)
        } else {
            print("Subscription product not found")
        }
    }
}

struct SettingButton: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal)
            .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            .background(Color(#colorLiteral(red: 0.231372549, green: 0.4470588235, blue: 0.9294117647, alpha: 1)))
            .cornerRadius(20)
            .padding(.top, 16)
    }
}

struct LogoutButton: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal)
            .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            .background(Color.red)
            .cornerRadius(20)
            .padding(.top, 16)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

