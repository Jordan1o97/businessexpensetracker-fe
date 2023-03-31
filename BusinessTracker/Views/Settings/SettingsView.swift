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
    @State private var buyingAd = true
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var showSpinner = false
    @State private var showDeleteUserAlert = false
    @State private var showSubscriptionView = false
    //This is my update for the branch
    
    var body: some View {
        VStack {
            customTitleView()
                .padding(.top, 50)
            Form {
                if accountType == "free" {
                    BannerView(adUnitID: "ca-app-pub-9324761796430059/9535673072")
                        .frame(height: 50)
                        .listRowInsets(EdgeInsets())
                }
                managersSection()
                accountSection()
                actionsSection()
                linksSection()
            }
        }
    }

    private func managersSection() -> some View {
        Section(header: Text("Managers")) {
            settingsButton(title: "Category Manager", isPresented: $showCategoryManager, view: AnyView(CategorySettingView(isPresented: $showCategoryManager)))
            settingsButton(title: "Client Manager", isPresented: $showClientManager, view: AnyView(ClientSettingView(isPresented: $showClientManager)))
            settingsButton(title: "Vehicle Manager", isPresented: $showVehicleManager, view: AnyView(VehicleSettingView(isPresented: $showVehicleManager)))
        }
    }

    private func accountSection() -> some View {
        Section(header: Text("Account")) {
            settingsButton(title: "Subscribe", isPresented: $showSubscriptionView, view: AnyView(SubscriptionPromptView(isPresented: $showSubscriptionView)))
        }
    }

    private func actionsSection() -> some View {
        Section(header: Text("Actions")) {
            deleteUserButton(title: "Delete User")
                .alert(isPresented: $showDeleteUserAlert) {
                    Alert(title: Text("Delete User"),
                          message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                          primaryButton: .destructive(Text("Delete"), action: deleteUserAndLogout),
                          secondaryButton: .cancel())
                }
            deleteUserButton(title: "Logout")
                .alert(isPresented: $showDeleteUserAlert) {
                    Alert(title: Text("Logout"),
                          message: Text("Are you sure you want to log out?"),
                          primaryButton: .destructive(Text("Logout"), action: logout),
                          secondaryButton: .cancel())
                }
        }
        .fullScreenCover(isPresented: $showSignIn, content: { SignInView() })
    }

    private func settingsButton(title: String, isPresented: Binding<Bool>, view: AnyView) -> some View {
        Button(action: { isPresented.wrappedValue.toggle() }) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .sheet(isPresented: isPresented, content: { view })
    }

    private func deleteUserButton(title: String) -> some View {
        Button(action: { showDeleteUserAlert.toggle() }) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
    
    private func linksSection() -> some View {
        HStack {
            LinkButton(title: "Privacy Policy", url: URL(string: "http://icubemedia.ca/privacy-policy.html")!)
            Spacer()
            LinkButton(title: "Terms of Service", url: URL(string: "http://icubemedia.ca/trems.html")!)
            Spacer()
            LinkButton(title: "Support", url: URL(string: "http://icubemedia.ca/#contact_footer")!)
        }
    }
    
    private func customTitleView() -> some View {
        HStack {
            Spacer()
            Text("Settings")
                .font(.system(size: 22, weight: .bold))
            Spacer()
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.set(false, forKey: "rememberMe")
        subscriptionManager.stopCheckingSubscription()
        self.showSignIn = true;
    }
    
    func deleteUserAndLogout() {
        guard let userId = UserDefaults.standard.string(forKey: "userId"),
              let authToken = UserDefaults.standard.string(forKey: "token") else {
            print("User ID or token not found")
            return
        }
        self.showSpinner = true
        UserServie().deleteUser(userId: userId, authToken: authToken) { result in
            DispatchQueue.global(qos: .background).async {
                switch result {
                case .success(let statusCode):
                    if statusCode == 200 {
                        self.showSpinner = false
                        self.logout()
                        self.showSignIn = true
                    } else {
                        print("Unexpected status code: \(statusCode)")
                    }
                case .failure(let error):
                    print("Error deleting user: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct LinkButton: View {
    let title: String
    let url: URL
    
    var body: some View {
        Link(destination: url) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(Color.blue)
                .padding(.top, 16)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
