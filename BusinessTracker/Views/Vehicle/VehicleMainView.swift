//
//  VehicleMainView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-17.
//

import SwiftUI

struct VehicleMainView: View {
    @Binding var selectedVehicle: (name: String, id: String)
    @Binding var isPresented: Bool
    
    @State private var showAddVehicleView = false
    @State private var vehicles: [Vehicle] = []
    @State private var isAnimating: Bool = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all) // Set the background grey color
            VStack {
                BannerContainerView()
                HStack {
                    Text("Vehicle Tracker")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 50)

                    Spacer()

                    AdButton(onButtonAction: {
                        showAddVehicleView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 24, height: 24)
                    }
                    .padding(.trailing, 20) // Add custom padding to create a gap between the button and the right edge
                    .fullScreenCover(isPresented: $showAddVehicleView) {
                        AddVehicleView(isPresented: $showAddVehicleView)
                            .onDisappear(perform: fetchVehicles)
                    }
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack {
                        ForEach(vehicles) { vehicle in
                            AdButton(onButtonAction: {
                                selectedVehicle = (name: vehicle.name, id: vehicle.id)
                                isPresented = false
                            }) {
                                VehicleView(vehicle: vehicle)
                                    .padding(.horizontal)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                    .padding(.bottom, 10)
                                    .foregroundColor(.black) // Keep the text color black
                            }
                        }
                    }
                }
                .padding(.top)
                .frame(width: UIScreen.main.bounds.width * 0.90)
                .onAppear(perform: fetchVehicles)
                BannerContainerView()
            }
            if isAnimating {
                ActivityIndicatorView(isAnimating: isAnimating)
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
    }

    func fetchVehicles() {
        guard let userId = getCurrentUserId() else {
            print("User ID not found")
            return
        }

        guard let token = getToken() else {
            print("Token not found")
            return
        }

        self.isAnimating = true

        VehicleService().fetchVehiclesByUserId(userId: userId, authToken: token) { result in
            switch result {
            case .success(let fetchedVehicles):
                DispatchQueue.global(qos: .background).async {
                    self.vehicles = fetchedVehicles
                    self.isAnimating = false
                    print("Vehicles: \(self.vehicles)")
                }
            case .failure(let error):
                print("Error fetching vehicles: \(error)")
                DispatchQueue.global(qos: .background).async {
                    self.isAnimating = false
                }
            }
        }
    }
}

struct VehicleMainView_Previews: PreviewProvider {
    @State static private var selectedVehicle = (name: "", id: "")
    @State static private var isPresented = true
    
    static var previews: some View {
        VehicleMainView(selectedVehicle: $selectedVehicle, isPresented: $isPresented)
    }
}
