//
//  SignUp.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-14.
//

import SwiftUI


struct SignUpView: View {
    @Binding var isPresented: Bool
    @State private var companyName = "Company Name"
    @State private var name = "Name"
    @Binding var email: String;
    @FocusState private var isCompanyNameFieldFocused: Bool
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isEmailFieldFocused: Bool
    @Binding var password: String;
    @State private var rememberMe = true 
    @State private var showPassword = false
    @State private var signUpButtonState: CustomButtonState = .normal
    @State private var showSpinner = false
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack() {
            VStack(alignment: .leading) {
                Text("Create an Account Now")
                    .font(.custom("Urbanist", size: 40))
                    .fontWeight(.bold)
                    .lineSpacing(11)
                    .padding(.top, 71)
                    .padding(.leading, 24)
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack {
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.white)
                            TextField("Company Name", text: $companyName)
                                .foregroundColor(.white)
                                .focused($isCompanyNameFieldFocused)
                                .onChange(of: isCompanyNameFieldFocused) { focused in
                                    if focused && companyName == "Company Name" {
                                        companyName = ""
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
                            Image(systemName: "person")
                                .foregroundColor(.white)
                            TextField("Name", text: $name)
                                .foregroundColor(.white)
                                .focused($isNameFieldFocused)
                                .onChange(of: isNameFieldFocused) { focused in
                                    if focused && name == "Name" {
                                        name = ""
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
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)
                HStack {
                    Spacer()
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top)
                    Spacer()
                }
                HStack {
                    Spacer()
                    CustomActionButton(
                        buttonState: $signUpButtonState,
                        buttonText: "Sign Up",
                        errorText: "Try Again",
                        requiredFields: [name, companyName, email, password]
                    ) {
                        if !name.isEmpty && !companyName.isEmpty && !email.isEmpty && !password.isEmpty {
                            // Perform sign up action
                            signUpButtonState = .normal
                            self.showSpinner = true
                            UserServie().signUp(accountType: "free", username: email, password: password, name: name, companyName: companyName) { result in
                                self.showSpinner = false
                                switch result {
                                case .success(let user):
                                    print("User created successfully: \(user)")
                                    // Navigate to the next view or show a success message
                                    self.isPresented = false
                                case .failure(let error):
                                    print("Error creating user: \(error)")
                                    // Show an error message and update the button state
                                    signUpButtonState = .error
                                    if let userServiceError = error as? UserServiceError, userServiceError == .emailAlreadyInUse {
                                        errorMessage = "Email is already in use."
                                    } else {
                                        errorMessage = "An error occurred. Please try again."
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.top, 60)
                Spacer()
                HStack {
                    Spacer()
                    Text("Have an account?")
                        .font(.custom("Urbanist", size: 16))
                        .fontWeight(.bold)
                        .lineSpacing(22)
                    Button(action: {
                        // Navigate to sign in page
                        self.isPresented = false
                    }) {
                        Text("Sign In")
                            .font(.custom("Urbanist", size: 16))
                            .fontWeight(.bold)
                            .lineSpacing(22)
                            .foregroundColor(.blue)
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
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .padding(.leading)
                .background(configuration.isOn ? Color.blue : Color.clear)
                .cornerRadius(41)
        }
    }
}

//struct SignUnView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView(isPresented: .constant(true))
//    }
//}
