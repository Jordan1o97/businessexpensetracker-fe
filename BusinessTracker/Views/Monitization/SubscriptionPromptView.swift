//
//  SubscriptionPromptView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-27.
//

import SwiftUI

struct SubscriptionPromptView: View {
    @Binding var isPresented: Bool
    @StateObject private var iapManager = InAppPurchaseManager.shared
    @State private var isLoading = false
    @State private var disableTouch = false
    
    var body: some View {
<<<<<<< HEAD
        VStack {
            Spacer()

            Text("Subscribe To Disable Ads")
                .font(.title)
                .bold()
                .padding(.top)
                .multilineTextAlignment(.center)
            
            Spacer()
            
=======
        ZStack {
>>>>>>> 6280be9dbfc842bd6148564493296bbea61b6f00
            VStack {
                Text("Subscribe \nTo \nDisable Ads")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                VStack {
                    Text("Monthly Subscription")
                        .font(.title2)
                        .bold()
                    
                    Text("$3.99 / month")
                        .font(.title)
                        .bold()
                        .padding(.bottom)
                    
                    Text("Subscriptions automatically renew unless turned off in your account settings at least 24 hours before the end of the current period. Payment is charged to your Apple account. Subscribing will remove ads in app.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        Button(action: {
                            disableAds()
                        }) {
                            Text("Subscribe")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Not Now")
                            .foregroundColor(.blue)
                            .padding(.top)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .padding(.horizontal)
                
                Spacer()
                
                VStack {
                    Text("Read our")
                    HStack {
                        Link("Terms", destination: URL(string: "http://icubemedia.ca/trems.html")!)
                        Text("and")
                        Link("Privacy Policy", destination: URL(string: "http://icubemedia.ca/privacy-policy.html")!)
                    }
                }
                .foregroundColor(.blue)
                .font(.caption)
                .padding(.bottom)
            }
<<<<<<< HEAD
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .padding(.horizontal)
            
            Spacer()
            
                HStack {
                    Text("Read our")

                    Link(destination: URL(string: "http://icubemedia.ca/trems.html")!, label: {
                        Text("Terms")
                            .underline()
                    })
                    
                    Text("and").underline()
                    
                    Link(destination: URL(string: "http://icubemedia.ca/privacy-policy.html")!, label: {
                        Text("Policy")
                            .underline()
                    })
=======
            if disableTouch {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {}
                    .allowsHitTesting(true)
>>>>>>> 6280be9dbfc842bd6148564493296bbea61b6f00
            }
        }
        .onChange(of: isLoading) { newValue in
            disableTouch = newValue
        }
    }
    
    private func disableAds() {
        isLoading = true
        if let product = iapManager.subscriptionProduct {
            iapManager.purchase(product: product) {
                self.isLoading = false
                self.isPresented = false
            }
        } else {
            print("Subscription product not found")
        }
    }
}

struct SubscriptionPromptView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionPromptView(isPresented: .constant(true))
    }
}

