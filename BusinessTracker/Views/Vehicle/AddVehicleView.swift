//
//  AddVehicleView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-17.
//

import SwiftUI

struct AddVehicleView: View {
    @Binding var isPresented: Bool

    @State private var name: String = ""
    @State private var isLoading: Bool = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")

    var canSave: Bool {
        return !name.isEmpty
    }

    func createVehicle() {
        isLoading = true

        let newVehicle = Vehicle(id: UUID().uuidString, name: name)

        guard let token = getToken() else {
            print("Token not found")
            return
        }
        DispatchQueue.global(qos: .background).async {
            VehicleService().createVehicle(vehicle: newVehicle, authToken: token) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let vehicle):
                        print("Vehicle saved: \(vehicle)")
                        isPresented = false
                    case .failure(let error):
                        print("Error saving vehicle: \(error)")
                        isPresented = false
                    }
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

                    Text("New Vehicle")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 20)

                    Spacer()

                    AdButton(onButtonAction: {
                        createVehicle()
                    }) {
                        Text("Save")
                            .foregroundColor(canSave ? .blue : .gray)
                    }
                    .disabled(!canSave)
                    .padding(.trailing, 20)
                }

                Form {
                    HStack {
                        Text("Name: ")
                        TextField("Ford F150", text: $name)
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
    }
}

struct AddVehicleView_Previews: PreviewProvider {
    static var previews: some View {
        AddVehicleView(isPresented: .constant(true))
    }
}
