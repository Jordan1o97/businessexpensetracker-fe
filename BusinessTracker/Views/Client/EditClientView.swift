//
//  EditClientView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-16.
//

import SwiftUI

struct EditClientView: View {
    @Binding var isPresented: Bool
    @State var client: Client

    @State private var name: String = ""
    @State private var emailAddress: String = ""
    @State private var officePhone: String = ""
    @State private var mobilePhone: String = ""
    @State private var addressLine1: String = ""
    @State private var addressLine2: String = ""
    @State private var city: String = ""
    @State private var stateOrProvince: String = ""
    @State private var postalCode: String = ""
    @State private var country: String = ""
    @State private var isLoading: Bool = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")

    var canSave: Bool {
        return !name.isEmpty
    }

    func saveClient() {
        isLoading = true

        let newClient = Client(id: client.id, name: name, emailAddress: emailAddress, officePhone: officePhone, mobilePhone: mobilePhone, addressLine1: addressLine1, addressLine2: addressLine2, city: city, stateOrProvince: stateOrProvince, postalCode: postalCode, country: country)

        guard let token = getToken() else {
            print("Token not found")
            return
        }

        ClientService().saveClient(client: newClient, authToken: token) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let client):
                    print("Client saved: \(client)")
                    isPresented = false
                case .failure(let error):
                    print("Error saving client: \(error)")
                    isPresented = false
                }
            }
        }
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)

            VStack {
                BannerContainerView()
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 20)

                    Spacer()

                    Text("New Client")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 20)

                    Spacer()

                    AdButton(onButtonAction: {
                        saveClient()
                    }) {
                        Text("Save")
                            .foregroundColor(canSave ? .blue : .gray)
                    }
                    .disabled(!canSave)
                    .padding(.trailing, 20)
                }

                Form {
                    Section {
                        HStack {
                            Text("Name:")
                            TextField("Name", text: $name)
                        }
                        HStack {
                            Text("Email Address:")
                            TextField("Email Address", text: $emailAddress)
                                .keyboardType(.emailAddress)
                        }
                        HStack {
                            Text("Office Phone:")
                            TextField("Office Phone", text: $officePhone)
                                .keyboardType(.phonePad)
                        }
                        HStack {
                            Text("Mobile Phone:")
                            TextField("Mobile Phone", text: $mobilePhone)
                                .keyboardType(.phonePad)
                        }
                        HStack {
                            Text("Address Line 1:")
                            TextField("Address Line 1", text: $addressLine1)
                        }
                        HStack {
                            Text("Address Line 2:")
                            TextField("Address Line 2", text: $addressLine2)
                        }
                        HStack {
                            Text("City:")
                            TextField("City", text: $city)
                        }
                        HStack {
                            Text("State/Province:")
                            TextField("State/Province", text: $stateOrProvince)
                        }
                        HStack {
                            Text("Postal Code:")
                            TextField("Postal Code", text: $postalCode)
                        }
                        HStack {
                            Text("Country:")
                            TextField("Country", text: $country)
                        }
                    }
                }

                Spacer()
            }

            if isLoading {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ActivityIndicatorView(isAnimating: isLoading)
                        Spacer()
                    }
                    Spacer()
                }
                .background(Color(.systemBackground).opacity(0.8))
                .edgesIgnoringSafeArea(.all)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { _ in
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
        .onAppear() {
            self.name = client.name
            self.emailAddress = client.emailAddress ?? ""
            self.officePhone = client.officePhone ?? ""
            self.mobilePhone = client.mobilePhone ?? ""
            self.addressLine1 = client.addressLine1 ?? ""
            self.addressLine2 = client.addressLine2 ?? ""
            self.city = client.city ?? ""
            self.stateOrProvince = client.stateOrProvince ?? ""
            self.postalCode = client.postalCode ?? ""
            self.country = client.country ?? ""
        }
    }
}

struct EditClientView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleClient = Client(id: "c7852d88-aa90-4386-9671-839970522468",
                                  name: "John Doe",
                                  emailAddress: "john.doe@example.com",
                                  officePhone: "555-123-4567",
                                  mobilePhone: "555-987-6543",
                                  addressLine1: "123 Main St",
                                  addressLine2: "Apt 4B",
                                  city: "New York",
                                  stateOrProvince: "NY",
                                  postalCode: "10001",
                                  country: "USA")
        EditClientView(isPresented: .constant(true), client: sampleClient)
    }
}