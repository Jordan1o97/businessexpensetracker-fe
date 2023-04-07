//
//  AddTripLogView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-16.
//

import SwiftUI

struct AddTripLogView: View {
    @Binding var isPresented: Bool

    @State private var date: Date = Date()
    @State private var expense: String = ""
    @State private var start: Date = Date()
    @State private var end: Date = Date()
    @State private var totalHours: String = ""
    @State private var rate: String = ""
    @State private var total: String = ""
    @State private var origin: String = ""
    @State private var destination: String = ""
    @State private var clientId: (name: String, id: String) = ("", "")
    @State private var vehicleId: (name: String, id: String) = ("", "")
    @State private var notes: String = ""
    @State private var isLoading: Bool = false
    @State private var showClientMainView = false
    @State private var showVehicleMainView = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    @State private var disableTouch = false

    var editMode: Bool = false // Set this to true when editing an existing trip log

    var canSave: Bool {
        return !expense.isEmpty && !origin.isEmpty && !destination.isEmpty && !clientId.id.isEmpty && !vehicleId.id.isEmpty
    }

    func createTripLog() {
        isLoading = true
        
        let tripLogId = UUID().uuidString; // Replace with the existing trip log ID when in edit mode
        let newTripLog = TripLog(id: tripLogId, date: date, expense: Double(expense) ?? 0.0, start: start, end: end, totalHours: Double(totalHours) ?? 0.0, rate: Double(rate) ?? 0.0, total: Double(total) ?? 0.0, vehicle: vehicleId.id, origin: origin, destination: destination, clientId: clientId.id, notes: notes) // Replace userId with the actual userId
        
        guard let token = getToken() else {
            print("Token not found")
            return
        }
        DispatchQueue.global(qos: .background).async {
            TriplogService().createTripLog(tripLog: newTripLog, authToken: token) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let message):
                        print(message)
                        isPresented = false
                    case .failure(let error):
                        print("Error saving trip log: \(error)")
                    }
                }
            }
        }
        isPresented = false
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
                    
                    Text(editMode ? "Edit Trip Log" : "New Trip Log")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    AdButton(onButtonAction: {
                        createTripLog()
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
                            Text("Date:")
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                        }
                        HStack {
                            Text("Expense:")
                            TextField("100.00", text: $expense)
                                .keyboardType(.numberPad)
                        }
                        HStack {
                            Text("Start:")
                            DatePicker("Start", selection: $start, displayedComponents: [.date, .hourAndMinute])
                        }
                        HStack {
                            Text("End:")
                            DatePicker("End", selection: $end, displayedComponents: [.date, .hourAndMinute])
                        }
                        HStack {
                            Text("totalHours:")
                            TextField("8", text: $totalHours)
                                .keyboardType(.numberPad)
                        }
                        HStack {
                            Text("Rate:")
                            TextField("1.50", text: $rate)
                                .keyboardType(.numberPad)
                        }
                        HStack {
                            Text("Total:")
                            TextField("225.00", text: $total)
                                .keyboardType(.numberPad)
                        }
                        HStack {
                            Text("Origin:")
                            TextField("Halifax, NS", text: $origin)
                        }
                        HStack {
                            Text("Destination:")
                            TextField("Toronto, ON", text: $destination)
                        }
                        HStack {
                            Text("Notes:")
                            TextField("Very Sceneic Drive", text: $notes)
                        }
                    }
                    Section {
                        HStack {
                            Text("Client:")
                            AdButton(onButtonAction: {
                                showClientMainView.toggle()
                            }) {
                                Text(clientId.name.isEmpty ? "Apple" : "\(clientId.name)")
                                    .foregroundColor(clientId.name.isEmpty ? .gray : .primary)
                            }
                            .sheet(isPresented: $showClientMainView) {
                                ClientMainView(selectedClient: $clientId, isPresented: $showClientMainView)
                            }
                        }

                        HStack {
                            Text("Vehicle:")
                            AdButton(onButtonAction: {
                                showVehicleMainView.toggle()
                            }) {
                                Text(vehicleId.name.isEmpty ? "Ford F150" : "\(vehicleId.name)")
                                    .foregroundColor(vehicleId.name.isEmpty ? .gray : .primary)
                            }
                            .sheet(isPresented: $showVehicleMainView) {
                                VehicleMainView(selectedVehicle: $vehicleId, isPresented: $showVehicleMainView)
                            }
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
    }
}

struct AddTripLogView_Previews: PreviewProvider {
    static var previews: some View {
        AddTripLogView(isPresented: .constant(true))
    }
}
