//
//  EditTripLogView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-16.
//

import SwiftUI

struct EditTripLogView: View {
    @Binding var isPresented: Bool
    @State var tripLog: TripLog
    
    @State private var date: Date = Date()
    @State private var expense: String = ""
    @State private var start: Date = Date()
    @State private var end: Date = Date()
    @State private var totalHours: String = ""
    @State private var rate: String = ""
    @State private var total: String = ""
    @State private var origin: String = ""
    @State private var destination: String = ""
    @State private var client: (name: String, id: String) = ("", "")
    @State private var vehicleId: (name: String, id: String) = ("", "")
    @State private var notes: String = ""
    @State private var isLoading: Bool = false
    @State private var showClientMainView = false
    @State private var showVehicleMainView = false
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    @State private var disableTouch = false

    var canSave: Bool {
        return !expense.isEmpty && !vehicleId.id.isEmpty && !origin.isEmpty && !destination.isEmpty && !client.id.isEmpty
    }

    func saveTripLog() {
        isLoading = true
        print(tripLog.id)
        let updatedTripLog = TripLog(id: tripLog.id, date: date, expense: Double(expense) ?? 0.0, start: start, end: end, totalHours: Double(totalHours) ?? 0.0, rate: Double(rate) ?? 0.0, total: Double(total) ?? 0.0, vehicle: vehicleId.id, origin: origin, destination: destination, clientId: client.id, notes: notes) // Replace userId with the actual userId
        
        guard let token = getToken() else {
            print("Token not found")
            return
        }
        DispatchQueue.global(qos: .background).async {
            TriplogService().updateTripLog(tripLog: updatedTripLog, authToken: token) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let message):
                        print("Trip log saved: \(message)")
                        isPresented = false
                    case .failure(let error):
                        print("Error saving trip log: \(error)")
                        isLoading = false
                    }
                }
            }
        }
        isPresented = false
    }
    
    func fetchClientName(clientId: String) {
        guard let token = getToken() else {
            print("Token not found")
            return
        }
        
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            ClientService().fetchClientById(clientId: clientId, authToken: token) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let client):
                        self.client = (name: client.name, id: client.id)
                    case .failure(let error):
                        print("Error fetching client name: \(error)")
                    }
                }
            }
        }
    }
    
    func fetchVehicleName(vehicleId: String) {
        guard let token = getToken() else {
            print("Token not found")
            return
        }
        
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            VehicleService().fetchVehicleById(vehicleId: vehicleId, authToken: token) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let vehicle):
                        self.vehicleId = (name: vehicle.name, id: vehicle.id)
                    case .failure(let error):
                        print("Error fetching vehicle name: \(error)")
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
                    
                    Text("Edit Trip Log")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    AdButton(onButtonAction: {
                        saveTripLog()
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
                                Text(client.name.isEmpty ? "Apple" : "\(client.name)")
                                    .foregroundColor(client.name.isEmpty ? .gray : .primary)
                            }
                            .sheet(isPresented: $showClientMainView) {
                                ClientMainView(selectedClient: $client, isPresented: $showClientMainView)
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
        .onAppear() {
            self.date = tripLog.date
            self.expense = String(tripLog.expense)
            self.start = tripLog.start
            self.end = tripLog.end
            self.totalHours = String(tripLog.totalHours)
            self.rate = String(tripLog.rate)
            self.total = String(tripLog.total)
            self.origin = tripLog.origin
            self.destination = tripLog.destination
            fetchClientName(clientId: tripLog.clientId)
            fetchVehicleName(vehicleId: tripLog.vehicle)
        }
    }
}

struct EditTripLogView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTripLog = TripLog(id: "1a2b3c4d",
                                    date: Date(),
                                    expense: 100.0,
                                    start: Date(),
                                    end: Date(),
                                    totalHours: 8,
                                    rate: 0.58,
                                    total: 116.0,
                                    vehicle: "Car",
                                    origin: "Origin",
                                    destination: "Destination",
                                    clientId: "c7852d88-aa90-4386-9671-839970522468",
                                    notes: "Sample notes")
        EditTripLogView(isPresented: .constant(true), tripLog: sampleTripLog)
    }
}
