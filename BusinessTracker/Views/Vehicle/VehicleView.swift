//
//  VehicleView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-17.
//

import SwiftUI

struct VehicleView: View {
    var vehicle: Vehicle
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(vehicle.name)
                .font(.headline)
            
            Divider()
            
            // Add extra data here in the future
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray5) : Color.white)
        .cornerRadius(10)
    }
}

struct VehicleView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleVehicle = Vehicle(id: "v1234-abcd-5678-efgh",
                                    name: "Vehicle 1")
        
        VehicleView(vehicle: sampleVehicle)
    }
}
