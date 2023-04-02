//
//  ClientView.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-16.
//

import SwiftUI

struct ClientView: View {
    var client: Client
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(client.name)
                .font(.headline)
            
            Divider()
            
            HStack {
                Text(client.emailAddress ?? "No Email")
                    .font(.subheadline)
                Spacer()
                Text(client.officePhone ?? "No Office Phone")
                    .font(.subheadline)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray5) : Color.white)
        .cornerRadius(10)
    }
}

struct ClientView_Previews: PreviewProvider {
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
        
        ClientView(client: sampleClient)
    }
}
