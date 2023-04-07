//
//  EditVehicleView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-20.
//

import SwiftUI

struct EditVehicleView: View {
    @Binding var isPresented: Bool
    @State var vehicle: Vehicle

    @State private var name: String = ""
    @State private var isLoading: Bool = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    @State private var disableTouch = false

    var canSave: Bool {
        return !name.isEmpty
    }

    func saveVehicle() {
        isLoading = true

        let newVehicle = Vehicle(id: vehicle.id, name: name)

        guard let token = getToken() else {
            print("Token not found")
            return
        }
        DispatchQueue.global(qos: .background).async {
            VehicleService().saveVehicle(vehicle: newVehicle, authToken: token) { result in
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

                    Text("Edit Vehicle")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 20)

                    Spacer()

                    AdButton(onButtonAction: {
                        saveVehicle()
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
            if disableTouch {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {}
                    .allowsHitTesting(true)
            }
        }
        .onChange(of: isLoading) { newValue in
            disableTouch = newValue
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { _ in
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
        .onAppear() {
            self.name = vehicle.name
        }
    }
}

struct EditVehicleView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleVehicle = Vehicle(id: "v1234-abcd-5678-efgh",
                                    name: "Vehicle 1")
        EditVehicleView(isPresented: .constant(true), vehicle: sampleVehicle)
    }
}

