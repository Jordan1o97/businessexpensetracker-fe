//
//  SignInView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-14.
//

import SwiftUI


struct SignInView: View {
    @State private var email: String = "Email"
    @FocusState private var isEmailFieldFocused: Bool
    @State private var password = ""
    @State private var rememberMe = UserDefaults.standard.bool(forKey: "rememberMe")
    @State private var showPassword = false
    @State private var signInButtonState: CustomButtonState = .normal
    @State private var showMainView = false
    @State private var showSpinner = false
    @State private var isSignUpViewShowing = false

    var body: some View {
        NavigationView {
            ZStack() {
                VStack(alignment: .leading) {
                    Text("Log into your")
                        .font(.custom("Urbanist", size: 40))
                        .fontWeight(.bold)
                        .lineSpacing(11)
                        .padding(.top, 71)
                        .padding(.bottom, 1)
                        .padding(.leading, 24)
                    Text("Account")
                        .font(.custom("Urbanist", size: 40))
                        .fontWeight(.bold)
                        .lineSpacing(11)
                        .padding(.leading, 24)
                    Spacer();
                    VStack(alignment: .leading, spacing: 20) {
                        VStack {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.white)
                                TextField("Email", text: $email)
                                    .foregroundColor(.white)
                                    .focused($isEmailFieldFocused)
                                    .onChange(of: isEmailFieldFocused) { focused in
                                        if focused && email == "Email" {
                                            email = ""
                                        }
                                    }
                            }
                            Divider()
                        }
                        .padding(12)
                        .background(Color.black)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        
                        VStack {
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.white)
                                if showPassword {
                                    TextField("Password", text: $password)
                                        .foregroundColor(.white) // add this line to change the text color to white
                                } else {
                                    SecureField("Password", text: $password)
                                        .foregroundColor(.white) // add this line to change the text color to white
                                }
                                Button(action: { self.showPassword.toggle() }) {
                                    Image(systemName: self.showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.white)
                                }
                            }
                            Divider()
                        }
                        .padding(12)
                        .background(Color.black)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                self.rememberMe.toggle()
                                UserDefaults.standard.set(rememberMe, forKey: "rememberMe")
                                if rememberMe {
                                    UserDefaults.standard.set(email, forKey: "rememberedEmail")
                                } else {
                                    UserDefaults.standard.removeObject(forKey: "rememberedEmail")
                                    email = "Email"
                                }
                            }) {
                                Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding(.trailing, 8)
                            }
                            Text("Remember Me")
                                .font(.custom("Urbanist", size: 16))
                                .fontWeight(.bold)
                                .lineSpacing(22)
                            Spacer()
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 24)
                    
                    HStack {
                        Spacer()
                        CustomActionButton(
                            buttonState: $signInButtonState,
                            buttonText: "Sign In",
                            errorText: "Try Again",
                            requiredFields: [email, password]
                        ) {
                            if !email.isEmpty && !password.isEmpty {
                                signInButtonState = .normal
                                self.showSpinner = true
                                UserServie().signIn(username: email, password: password) { result in
                                    self.showSpinner = false
                                    switch result {
                                    case .success(let data):
                                        print("User signed in successfully. Token: \(data.token), UserId: \(data.userId)")
                                        
                                        // Store the token and userId in UserDefaults
                                        UserDefaults.standard.set(data.token, forKey: "token")
                                        UserDefaults.standard.set(data.userId, forKey: "userId")
                                        UserDefaults.standard.set(data.accountType, forKey: "accountType")
                                        
                                        // Navigate to the next view or show a success message
                                        self.showMainView = true
                                    case .failure(let error):
                                        print("Error signing in: \(error)")
                                        
                                        // Show an error message and update the button state
                                        signInButtonState = .error
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Don't have an account?")
                            .font(.custom("Urbanist", size: 16))
                            .fontWeight(.bold)
                            .lineSpacing(22)
                        Button(action: {
                            self.isSignUpViewShowing = true
                        }) {
                            Text("Sign Up")
                                .font(.custom("Urbanist", size: 16))
                                .fontWeight(.bold)
                                .lineSpacing(22)
                                .foregroundColor(.blue)
                        }
                        .fullScreenCover(isPresented: $isSignUpViewShowing) {
                            SignUpView(isPresented: $isSignUpViewShowing)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
                if showSpinner {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .opacity(0.7)
                        .frame(width: 100, height: 100)
                        .overlay(ActivityIndicatorView(isAnimating: showSpinner))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            .gesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onEnded { _ in
                        hideKeyboard()
                    }
            )
            .background(
                NavigationLink("", destination: MainView(), isActive: $showMainView)
                    .opacity(0) // Make the navigation link invisible
            )
            .onAppear { // Add this modifier
                if UserDefaults.standard.bool(forKey: "rememberMe") {
                    email = UserDefaults.standard.string(forKey: "rememberedEmail") ?? "Email"
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
                        


struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
