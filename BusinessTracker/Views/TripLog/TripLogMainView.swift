//
//  TripLogMainView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-16.
//

import SwiftUI

struct TripLogMainView: View {
    @State private var selectedFilter: Int = 0
    @State private var showAddTripLogView = false
    @State private var tripLogs: [TripLog] = []
    @State private var clientNames: [String: String] = [:]
    @State private var vehicleNames: [String: String] = [:]
    @State private var isAnimating: Bool = false
    @State private var groupedTripLogs: [(String, [TripLog])] = []
    @State private var isEditViewPresented = false
    @State private var selectedTripLog: TripLog?
    @State private var accountType = UserDefaults.standard.string(forKey: "accountType")
    @State private var disableTouch = false
    @Environment(\.colorScheme) var colorScheme

    private let filterTitles = ["Day", "Month", "Year", "Vehicle", "Client"]

    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all) // Set the background grey color
            VStack {
                BannerContainerView();
                HStack {
                    Text("Trip Log")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.leading, 50)

                    Spacer()

                    AdButton(onButtonAction: {
                        showAddTripLogView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(width: 24, height: 24)
                    }
                    .padding(.trailing, 20) // Add custom padding to create a gap between the button and the right edge
                    .sheet(isPresented: $showAddTripLogView) {
                         AddTripLogView(isPresented: $showAddTripLogView)
                            .onDisappear(perform: fetchTripLogs)
                    }
                }
                .padding(.horizontal)

                FilterBarView(filterTitles: filterTitles, selectedFilter: $selectedFilter)
                    .frame(width: UIScreen.main.bounds.width, height: 50)
                    .padding(.top, 16)
                    .onChange(of: selectedFilter) { _ in
                        fetchTripLogs()
                    }

                ScrollView {
                    VStack {
                        ForEach(groupedTripLogs, id: \.0) { group in
                            Text(getGroupHeader(group: group))
                                .font(.system(size: 18, weight: .bold))
                                .padding(.top)
                            ForEach(group.1) { tripLog in
                                if let clientName = clientNames[tripLog.clientId],
                                   let vehicleName = vehicleNames[tripLog.vehicle] {
                                    AdButton(onButtonAction: {
                                        selectedTripLog = tripLog
                                        isEditViewPresented = true
                                    }) {
                                        TripLogView(tripLog: tripLog, clientName: clientName, vehicleName: vehicleName)
                                            .padding(.horizontal)
                                            .background(colorScheme == .dark ? Color(.systemGray5) : Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                            .padding(.bottom, 10)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top)
                .frame(width: UIScreen.main.bounds.width * 0.90)
                .onAppear(perform: fetchTripLogs)
                .sheet(isPresented: Binding(get: { isEditViewPresented }, set: { isEditViewPresented = $0 })) {
                    EditTripLogView(isPresented: Binding(get: { isEditViewPresented }, set: { isEditViewPresented = $0 }), tripLog: selectedTripLog!)
                        .onDisappear(perform: fetchTripLogs)
                }
                BannerContainerView();
            }
            if isAnimating {
                ActivityIndicatorView(isAnimating: isAnimating)
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            if disableTouch {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {}
                    .allowsHitTesting(true)
            }
        }
        .onChange(of: isAnimating) { newValue in
            disableTouch = newValue
        }
    }
    
    func getGroupHeader(group: (String, [TripLog])) -> String {
        if selectedFilter == 0 { // If the Day filter is selected
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            if let date = dateFormatter.date(from: group.0) {
                dateFormatter.dateFormat = "MMMM d, yyyy"
                return dateFormatter.string(from: date)
            }
        }
        return group.0
    }

    func fetchTripLogs() {
        guard let userId = getCurrentUserId() else {
            print("User ID not found")
            return
        }
        
        guard let token = getToken() else {
            print("Token not found")
            return
        }
        
        self.isAnimating = true
        DispatchQueue.global(qos: .background).async {
            TriplogService().fetchFilteredTripLogClientsAndVehicles(userId: userId, authToken: token, selectedFilter: selectedFilter) { result in
                switch result {
                case .success(let (groupedTripLogs, clientNames, vehicleNames)):
                    DispatchQueue.main.async {
                        _ = groupedTripLogs.map { (key, tripLogs) -> (String, [TripLog]) in
                            if selectedFilter == 1 || selectedFilter == 2 || selectedFilter == 3 {
                                let groupedTripLogs = tripLogs.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
                                return (key, groupedTripLogs)
                            } else {
                                return (key, tripLogs)
                            }
                        }
                        self.tripLogs = groupedTripLogs.flatMap { $0.1 } // Flatten the array of trip logs
                        self.clientNames = clientNames
                        self.vehicleNames = vehicleNames
                        self.groupedTripLogs = groupedTripLogs
                        self.isAnimating = false
                        print("groupedTripLogs: \(self.groupedTripLogs)")
                        print("Clients: \(self.clientNames)")
                        print("Vehicles: \(self.vehicleNames)")
                    }
                case .failure(let error):
                    print("Error fetching trip logs, clients, and vehicles: \(error)")
                    DispatchQueue.global(qos: .background).async {
                        self.isAnimating = false
                    }
                }
            }
        }
        
    }
}

struct TripLogMainView_Previews: PreviewProvider {
    static var previews: some View {
        TripLogMainView()
    }
}

