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
    
    var body: some View {
        VStack {
            Spacer()

            Text("Subscribe To Disable Ads")
                .font(.title)
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
                
                Button(action: {
                    disableAds();
                }) {
                    Text("Subscribe")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
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
            }
            .foregroundColor(.blue)
            .font(.caption)
            .padding(.bottom)
        }
    }
    
    private func disableAds() {
        if let product = iapManager.subscriptionProduct {
            iapManager.purchase(product: product)
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

